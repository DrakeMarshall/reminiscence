//Snow storms happen frequently on the outpost. They heavily obscure vision, hinder motion, and freeze you.

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/datum/weather/blizzard
	name = "blizzard"
	desc = "A blizzard sweeps across the area, freezing the unprotected."

	telegraph_message = "<i>You hear the winds picking up.</i>"
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<i>A blizzard descends upon the outpost.</i>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "blizzard"

	overlay_blend_mode = 1

	end_message = "<i>The blizzard calms, and the winds settle down.</i>"
	end_duration = 300

	area_type = /area/snow
	target_trait = ZTRAIT_STATION

	immunity_type = "snow"

	probability = 90
	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/blizzard/telegraph()
	. = ..()
	var/list/inside_areas = list()
	var/list/outside_areas = list()
	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			outside_areas += place
		else
			inside_areas += place
		CHECK_TICK

	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas
	sound_wo.start()
	sound_wi.start()

/datum/weather/blizzard/start()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()
	sound_ao.start()
	sound_ai.start()

	for(var/area/A in impacted_areas)
		for(var/turf/open/T in A)
			spawn(rand(30, 500))
				T.frost_act()

/datum/weather/blizzard/wind_down()
	. = ..()
	sound_ao.stop()
	sound_ai.stop()
	sound_wo.start()
	sound_wi.start()

/datum/weather/blizzard/end()
	. = ..()
	sound_wo.stop()
	sound_wi.stop()

/datum/weather/blizzard/weather_act(mob/living/L)
	if(ismecha(L.loc)) return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/protected = 1 - H.get_cold_protection(45)
		H.adjust_bodytemperature(-rand(20, 30) * protected)
	else
		L.bodytemperature -= rand(20, 30)

/obj/item/staff/storm/blizzard
	name = "staff of blizzards"
	desc = "An ancient staff retrieved from the testing grounds of the dev team. It trails eucalpytus leaves as you move it."
	storm_type = /datum/weather/blizzard
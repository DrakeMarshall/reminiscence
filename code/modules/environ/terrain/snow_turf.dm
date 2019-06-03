/turf/open/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow/snow.dmi'
	icon_state = "snow"
	pixel_y = -4
	pixel_x = -4
	intact = 0
	initial_gas_mix = "o2=32;n2=92;TEMP=180" //Snow gear and internals recommended.
	planetary_atmos = TRUE

/turf/open/snow/proc/dig(burn=0)
	ScrapeAway()
	if(!burn && prob(15))
		new /obj/item/stack/sheet/mineral/snow(src)

/turf/open/snow/ex_act(severity, target)
	dig(1)
	return

/turf/open/snow/burn_tile()
	dig(1)
	return

/turf/open/snow/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0)
	return

/turf/open/snow/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/snow/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/snow/handle_slip()
	return

/turf/open/snow/singularity_act()
	dig(1)
	return

/turf/open/snow/can_have_cabling()
	return 0

/turf/open/snow/is_transition_turf()
	return 0

/turf/open/snow/acid_act(acidpwr, acid_volume)
	return 0

/turf/open/snow/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			if(istype(src, /turf/open/snow/dug))
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else if(istype(src, /turf/open/snow/top))
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 2)
			else if(istype(src, /turf/open/snow/trench))
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 2)
	return FALSE

/turf/open/snow/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a floor.</span>")
			PlaceOnTop(/turf/open/floor/plating)
			return TRUE
	return FALSE

/turf/open/snow/top
	smooth = SMOOTH_TRUE | SMOOTH_BORDER
	layer = CLOSED_TURF_LAYER
	canSmoothWith = list(/turf/open/snow/top)
	baseturfs = /turf/open/snow/dug
	slowdown = 2
	var/stepping = 0
	var/steps = 0
	var/mutable_appearance/print

/turf/open/snow/top/attackby(obj/item/C, mob/user, params)
	if(C.tool_behaviour == TOOL_SHOVEL)
		to_chat(user, "<span class='notice'>You shovel the snow.</span>")
		playsound(src, 'sound/effects/rustle1.ogg', 50, 1)
		dig()

/turf/open/snow/top/proc/add_print()
	if(steps >= 3)
		return
	steps += 1
	cut_overlay(src.print)
	src.print = mutable_appearance(src.icon, "step[steps]", BULLET_HOLE_LAYER)
	add_overlay(src.print)

/turf/open/snow/top/Entered(atom/movable/A)
	if(istype(A, /mob/living/carbon))
		var/mob/living/carbon/C = A
		if(C.movement_type & FLYING || C.throwing || !C.has_gravity() || C.lying)
			return ..()
		var/area/AR = get_area(src)
		if(AR.icon_state == "snow_storm") return ..()
		if(!stepping && steps < 3)
			stepping = 1
			spawn(2)
				if(!istype(src, /turf/open/snow/top)) return ..()
				stepping = 0
				src.add_print()
	return ..()

/turf/open/snow/top/basic
	smooth = SMOOTH_FALSE

/turf/open/snow/top/basic/Initialize() //Save a little bit of loading time by not bothering to smooth at the start of the game, since the icon is already correct.
	..()
	spawn(rand(200, 400))
		smooth = SMOOTH_TRUE | SMOOTH_BORDER

/turf/open/snow/dug
	icon_state = "dug"
	smooth = SMOOTH_FALSE
	layer = MID_TURF_LAYER
	slowdown = 0
	baseturfs = /turf/open/snow/trench

/turf/open/snow/dug/attackby(obj/item/C, mob/user, params)
	if(C.tool_behaviour == TOOL_SHOVEL)
		to_chat(user, "<span class='notice'>You begin digging away the packed snow...</span>")
		if(do_after(user, 35, target = src))
			to_chat(user, "<span class='notice'>You dig a trench.</span>")
			playsound(src, 'sound/effects/rustle1.ogg', 50, 1)
			dig()
	if(istype(C, /obj/item/stack/tile/plasteel))
		to_chat(user, "<span class='notice'>You start constructing a floor.</span>")
		if(do_after(user, 20, target = src))
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				PlaceOnTop(/turf/open/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")

/turf/open/snow/trench
	name = "pit"
	desc = "A deep hole in the snow."
	icon = 'icons/turf/snow/snow_trench.dmi'
	icon_state = "trench"
	pixel_y = 0
	pixel_x = 0
	smooth = SMOOTH_TRUE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/snow/trench)
	layer = SPACE_LAYER
	slowdown = 0
	trench = 1
	baseturfs = /turf/open/snow/trench

/turf/open/snow/trench/attackby(obj/item/C, mob/user, params)
	if(C.tool_behaviour == TOOL_SHOVEL)
		to_chat(user, "<span class='notice'>You can't dig any further!</span>")
	if(istype(C, /obj/item/stack/tile/plasteel))
		if(do_after(user, 40, target = src))
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(2))
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor over the pit.</span>")
				PlaceOnTop(/turf/open/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need two floor tiles to build a floor over a pit!</span>")
/*
Some nifty active concealment code. Objects take on the pattern of the turf they are located on over time.
Applies to clothing overlays as well as regular icons, allowing for nifty stealth suits and stuff.
Objects with higher lightness and components with higher rates/intensity and lower period are more stealthy.

-Drake
*/

/datum/component/stealth/pattern
	description = "It shifts slightly under your gaze and catches the light in unusual ways."
	var/rate = 80 //between 0 and 255, how much the suit changes each adjustment
	var/intensity = 0.8 //modifies lightness of icon
	var/period = 4 //Integer >0, how often the suit adjusts
	var/blend_mode = 2
	var/icon/background
	var/icon/base_icon
	var/counter = 0

/datum/component/stealth/pattern/Initialize()
	START_PROCESSING(SSobj, src)
	return ..()

/datum/component/stealth/pattern/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/stealth/pattern/RegisterWithParent()
	var/atom/holder = parent
	var/turf/T = get_turf(holder)
	create_background(T)
	base_icon = holder.icon
	..()

/datum/component/stealth/pattern/UnregisterFromParent()
	var/atom/holder = parent
	holder.icon = base_icon
	..()

/datum/component/stealth/pattern/process()
	counter++
	if(counter == period)
		counter = 0
		var/atom/holder = parent
		var/turf/T = get_turf(holder)
		var/icon/I = update_background(T)
		I -= rgb(0, 0, 0, rate)
		background.Blend(I, ICON_OVERLAY)
		if(!background)
			create_background(T)
		var/icon/I2 = icon(base_icon)
		I.SetIntensity(intensity)
		I2.Blend(background, blend_mode)
		holder.icon = I2
		if(istype(holder, /obj/item))
			var/obj/item/H = holder
			H.update_slot_icon()

/datum/component/stealth/pattern/proc/process_overlay(var/mutable_appearance/overlay)
	var/icon/I = icon(overlay.icon)
	I.Blend(background, blend_mode)
	overlay.icon = I
	return overlay

/datum/component/stealth/pattern/proc/create_background(var/turf/T)
	background = update_background(T)
	background.Insert(background, dir=NORTH)
	background.Insert(background, dir=SOUTH)
	background.Insert(background, dir=EAST)
	background.Insert(background, dir=WEST)

/datum/component/stealth/pattern/proc/update_background(var/turf/T)
	var/icon/I = icon(T.icon, T.icon_state)
	return I

/datum/reagent/cameleoline
	name = "Cameleoline"
	id = "cameleoline"
	description = "A rare metamaterial used in active stealth technology."
	reagent_state = LIQUID
	color = "#AAAAAA"
	taste_mult = 0

/datum/reagent/cameleoline/reaction_obj(obj/O, reac_volume)
	if(O && istype(O, /obj/item))
		var/obj/item/I = O
		if(reac_volume >= I.w_class*10)
			O.AddComponent(/datum/component/stealth/pattern)
	..()

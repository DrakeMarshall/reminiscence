//Empty space. Functionally a lot like Reebe void.
/turf/open/indestructible/sky
	name = "sky"
	icon_state = "sky"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/sky
	planetary_atmos = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/indestructible/sky/Initialize()
	..()
	new /obj/effect/step_trigger/fall(src)

/obj/structure/grav_suspender //Cosmetic structure to explain why the upper tower doesn't collapse if the lower part is damaged.
	name = "gravitic suspension unit"
	desc = "An extremely sturdy fixture that supports the weight of the control tower, preventing it from collapsing."
	icon = 'icons/obj/machines/gravity_generator.dmi' //Seems fitting, especially since there will not be a full gravity generator on this map.
	icon_state = "on_6" //on_6 and on_4 are the sides of the gravity generator
	resistance_flags = INDESTRUCTIBLE

/turf/open/indestructible/snowpath
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow/snow.dmi'
	icon_state = "dug"
	smooth = SMOOTH_FALSE
	layer = MID_TURF_LAYER
	pixel_y = -4
	pixel_x = -4
	intact = 0
	slowdown = 0
	initial_gas_mix = "o2=32;n2=92;TEMP=180"
	planetary_atmos = TRUE
	baseturfs = /turf/open/indestructible/snowpath

/turf/open/indestructible/snowpath/attackby(obj/item/C, mob/user, params)
	if(C.tool_behaviour == TOOL_SHOVEL)
		to_chat(user, "<span class='notice'>You can't dig here!</span>")
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
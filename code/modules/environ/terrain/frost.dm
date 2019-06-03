/*--------
FROST BASE
--------*/

/obj/effect/frost
	name = "frost"
	desc = "Frost clings to this surface."
	icon = 'icons/turf/snow/snow_overlays.dmi'
	icon_state = ""
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/effect/frost)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	density = FALSE

/obj/effect/frost/New()
	. = ..()
	queue_smooth(src)
	queue_smooth_neighbors(src)

/datum/component/frost
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/compatible
	var/static/list/blacklist = typecacheof(list(
		/turf/open/lava,
		/turf/open/space,
		/turf/open/water,
		/turf/open/chasm,
		/turf/open/snow)
		)

/datum/component/frost/Initialize(_amount)
	if( !compatible || !istype(parent, compatible) || blacklist[parent.type] )
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/flame_react)
	src.start()

/datum/component/frost/Destroy()
	src.end()
	return ..()

/datum/component/frost/proc/flame_react(exposed_temperature, exposed_volume)
	qdel(src)

/datum/component/frost/proc/attackby_react(obj/item/thing, mob/user, params)
	if(thing.is_hot())
		qdel(src)

/datum/component/frost/proc/start()
	return

/datum/component/frost/proc/end()
	return

/*---------
FLOOR FROST
---------*/

/datum/component/frost/floor
	compatible = /turf/open
	var/mutable_appearance/overlay

/datum/component/frost/floor/start()
	var/turf/open/master = parent
	overlay = mutable_appearance('icons/turf/snow/snow_overlays.dmi', "snowfloor", ABOVE_OPEN_TURF_LAYER)
	master.add_overlay(overlay)
	START_PROCESSING(SSwet_floors, src)

/datum/component/frost/floor/end()
	var/turf/open/master = parent
	master.cut_overlay(overlay)
	STOP_PROCESSING(SSwet_floors, src)

/datum/component/frost/floor/process()
	var/turf/open/T = get_turf(parent)
	if(T.GetTemperature() > T0C)
		qdel(src)

/*--------
WALL FROST
--------*/

/datum/component/frost/wall
	compatible = /turf/closed
	var/obj/effect/frost/effect

/datum/component/frost/wall/start()
	effect = new(parent)

/datum/component/frost/wall/end()
	qdel(effect)

/*----------
WINDOW FROST
----------*/

/datum/component/frost/wall/window
	compatible = /obj/structure/window

/datum/component/frost/wall/window/start()
	var/obj/structure/window/W = parent
	effect = new(get_turf(W))
	effect.layer = ABOVE_WINDOW_LAYER

/*----------------
FROST INTERACTIONS
----------------*/

/atom/proc/frost_act()
	return

/turf/open/frost_act()
	src.AddComponent(/datum/component/frost/floor)
	for(var/obj/structure/window/W in src.contents)
		W.frost_act()
	for(var/obj/machinery/door/airlock/A in src.contents)
		A.frost_act()

/turf/open/snow/frost_act()
	for(var/turf/T in orange(src, 1))
		if(!istype(T, /turf/open/snow))
			T.frost_act()

/turf/open/snow/top/frost_act()
	src.steps = 0
	src.cut_overlay(src.print)
	..()

/turf/closed/frost_act()
	src.AddComponent(/datum/component/frost/wall)

/obj/machinery/door/airlock/frost_act()
	src.freeze()

/obj/structure/window/frost_act()
	src.AddComponent(/datum/component/frost/wall/window)
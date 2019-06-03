//Not half bad, for 60 quick lines of code. Flavor-wise this makes a lot of sense for snow, and mechanics-wise this encourages defensive tactics by making you harder to hit while trenched.

/turf/open/var/trench = 0
/turf/open/var/trench_cooldown = 0
/atom/var/trenched = 0

/mob/living/CanPass(atom/movable/mover, turf/target)
	if(src.mob_size <= MOB_SIZE_HUMAN && trenched && istype(mover, /obj/item/projectile))
		var/obj/item/projectile/P = mover
		if(!P.trenched)
			return TRUE

/turf/open/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living) && mover.trenched && !src.trench)
		return 0
	return ..()

/turf/open/Entered(atom/movable/AM)
	if(src.trench && istype(AM, /mob/living))
		var/mob/living/M = AM
		if(M.movement_type & FLYING || M.throwing || !M.has_gravity())
			return ..()
		if(!M.trenched)
			to_chat(M, "<span class='notice'>You climb down into the pit.</span>")
			M.trenched = 1
			M.changeNext_move(CLICK_CD_CLICK_ABILITY)
	if(istype(AM, /obj/item/projectile))
		var/obj/item/projectile/P = AM
		if(P.trenched && !src.trench)
			P.trenched = 0
	return ..()

/turf/open/Bumped(atom/movable/AM)
	if(istype(AM, /mob/living))
		var/mob/living/M = AM
		if(world.time >= M.next_click && !trench_cooldown)
			M.changeNext_move(CLICK_CD_CLICK_ABILITY)
			trench_cooldown = 1
			spawn(15) trench_cooldown = 0
			to_chat(M, "<span class='notice'>You begin climbing out of the trench.</span>")
			if(do_after(M, 15, target = src))
				M.trenched = 0
				M.forceMove(src)
				to_chat(M, "<span class='notice'>You climb up out of the trench.</span>")
	return ..()
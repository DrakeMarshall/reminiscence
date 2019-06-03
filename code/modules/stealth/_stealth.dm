/*
Blend mode alteration
Opacity reduction
Color mimicry
Pattern mimicry
Afterimage creation
Hiding
*/

/datum/component/stealth
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/description

/datum/component/stealth/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/stealth/RegisterWithParent()
	if(description)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/stealth/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE))

/datum/component/stealth/proc/examine(datum/source, mob/user)
	to_chat(user, description)

/datum/component/stealth/color

/datum/component/stealth/blend

/datum/component/stealth/opacity

/datum/component/stealth/afterimage
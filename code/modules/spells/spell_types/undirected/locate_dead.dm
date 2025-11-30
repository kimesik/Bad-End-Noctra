/datum/action/cooldown/spell/undirected/locate_dead
	name = "Locate Corpse"
	desc = "Call upon the Undermaiden to guide you to a lost soul."
	button_icon_state = "necraeye"
	sound = 'sound/magic/whiteflame.ogg'

	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/skill/magic/holy
	required_items = list(/obj/item/clothing/neck/psycross/silver/necra)

	invocation = "Undermaiden, guide my hand to those who have lost their way."
	invocation_type = INVOCATION_WHISPER

	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 60 SECONDS
	spell_cost = 50

	var/datum/weakref/tracked_corpse

/datum/action/cooldown/spell/undirected/locate_dead/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/list/corpses = collect_corpses()
	if(!length(corpses))
		to_chat(owner, span_warning("The Undermaiden's grasp lets slip."))
		return . | SPELL_CANCEL_CAST

	var/selection = browser_input_list(owner, "Which body shall I seek?", "Available Bodies", corpses)
	if(QDELETED(src) || QDELETED(owner))
		return . | SPELL_CANCEL_CAST

	if(!selection)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	var/mob/living/corpse = corpses[selection]
	if(QDELETED(corpse))
		to_chat(owner, span_warning("The Undermaiden's grasp lets slip."))
		return . | SPELL_CANCEL_CAST

	tracked_corpse = WEAKREF(corpse)

/datum/action/cooldown/spell/undirected/locate_dead/cast(atom/cast_on)
	. = ..()
	var/mob/living/corpse = tracked_corpse?.resolve()
	if(QDELETED(corpse))
		to_chat(owner, span_warning("The Undermaiden's grasp lets slip."))
		return

	if(!is_in_zweb(owner.z, corpse.z))
		to_chat(owner, span_warning("The Undermaiden's grasp lets slip."))
		return

	var/direction_name = dir2text(get_dir(owner, corpse)) || "unknown"
	to_chat(owner, span_notice("The Undermaiden pulls on your hand, guiding you [direction_name]."))

/datum/action/cooldown/spell/undirected/locate_dead/proc/collect_corpses()
	if(!owner)
		return list()

	var/list/corpses = list()
	for(var/mob/living/C in GLOB.dead_mob_list)
		if(!C.mind)
			continue
		if(!is_in_zweb(owner.z, C.z))
			continue

		var/label = format_corpse_label(C)
		var/unique_label = label
		var/i = 1
		while(corpses[unique_label])
			i++
			unique_label = "[label] ([i])"

		corpses[unique_label] = C

	return corpses

/datum/action/cooldown/spell/undirected/locate_dead/proc/format_corpse_label(mob/living/corpse)
	var/time_dead = corpse.timeofdeath ? (world.time - corpse.timeofdeath) : 0
	var/time_label
	if(time_dead < 5 MINUTES)
		time_label = "Fresh corpse"
	else if(time_dead < 10 MINUTES)
		time_label = "Recently deceased"
	else if(time_dead < 30 MINUTES)
		time_label = "Long dead"
	else
		time_label = "Forgotten remains"

	var/name_text = corpse.get_visible_name()
	if(!name_text)
		name_text = "Unknown"

	return "[time_label] of [name_text]"

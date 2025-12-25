
/datum/sex_action/hole_storage/anus
	name = "Store/remove in anus"
	hole_id = ORGAN_SLOT_ANUS

/datum/sex_action/hole_storage/anus/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!target.getorganslot(ORGAN_SLOT_ANUS))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_ANUS))
		return FALSE
	if(user.used_intent.type == INTENT_GRAB)
		return TRUE //hacky but eh
	if(!user.get_active_held_item())
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/anus/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(user.used_intent.type == INTENT_GRAB || removing)
		return TRUE //hacky but eh
	if(!user.get_active_held_item())
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/anus/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	var/datum/sex_session/sex_session = get_sex_session(user, target)
	var/obj/item/dildo = user.get_active_held_item()

	self = (user == target)

	if(user.used_intent.type == INTENT_GRAB)
		if(self)
			user.visible_message(span_warning("I start removing items from my ass..."))
		else
			user.visible_message(span_warning("[user] starts removing items from [target]'s ass..."))
		removing = TRUE
	else
		if(self)
			user.visible_message(sex_session.spanify_force("I start inserting \the [dildo] in my ass..."))
		else
			user.visible_message(span_warning("[user] starts inserting \the [dildo] in [target]'s ass..."))
		removing = FALSE
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)


/datum/sex_action/hole_storage/anus/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/pain_amt = 3 //base pain amt to use

	var/datum/sex_session/sex_session = get_sex_session(user, target)

	if(removing)
		var/obj/item/removed_item
		removed_item = SEND_SIGNAL(user, COMSIG_HOLE_REMOVE_RANDOM_ITEM, hole_id, target, TRUE)
		if(!removed_item)
			user.visible_message(sex_session.spanify_force("I couldn't find anything inside..."))
			sex_session.desire_stop = TRUE
			return
		if(user.get_active_held_item())
			user.visible_message(sex_session.spanify_force("The [removed_item] falls down on the floor..."))
			removed_item.doMove(get_turf(user))
		else
			if(self)
				user.visible_message(sex_session.spanify_force("I fish out the [removed_item] from my ass..."))
			else
				user.visible_message(sex_session.spanify_force("I fish out the [removed_item] from [target]'s ass..."))
			removed_item.doMove(get_turf(user))
			user.put_in_active_hand(removed_item)
		sex_session.perform_sex_action(user, 0.5, pain_amt, !self)
		sex_session.handle_passive_ejaculation()

	else
		var/obj/item/dildo = user.get_active_held_item()
		var/success = SEND_SIGNAL(user, COMSIG_HOLE_TRY_FIT, dildo, hole_id, user, TRUE, FALSE)
		if(success)
			user.update_inv_hands()
			user.update_a_intents()
			if(self)
				user.visible_message(sex_session.spanify_force("I stuff the [dildo] in my ass..."))
			else
				user.visible_message(sex_session.spanify_force("I stuff the [dildo] in [target]'s ass..."))

		else
			if(self)
				user.visible_message(sex_session.spanify_force("I fail to stuff the [dildo] in my ass."))
			else
				user.visible_message(sex_session.spanify_force("I fail to stuff the [dildo] in [target]'s ass."))
			sex_session.desire_stop = TRUE
			return
		sex_session.perform_sex_action(user, 0.5, pain_amt, !self)
		sex_session.handle_passive_ejaculation()


/datum/sex_action/hole_storage/anus/on_finish(mob/living/user, mob/living/target)
	. = ..()
	removing = FALSE

/mob/living/carbon/get_embedded_objects()
	if(last_embedded_cache_time == world.time && cached_embedded_objects)
		return cached_embedded_objects
	var/list/all_embedded_objects = list()
	if(length(simple_embedded_objects))
		all_embedded_objects += simple_embedded_objects
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(!length(bodypart.embedded_objects))
			continue
		all_embedded_objects += bodypart.embedded_objects
	cached_embedded_objects = all_embedded_objects
	last_embedded_cache_time = world.time
	return all_embedded_objects

/mob/living/carbon/get_wounds()
	if(last_wounds_cache_time == world.time && cached_wounds)
		return cached_wounds
	var/list/all_wounds = list()
	if(length(simple_wounds))
		all_wounds += simple_wounds
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(!length(bodypart.wounds))
			continue
		all_wounds += bodypart.wounds
	cached_wounds = all_wounds
	last_wounds_cache_time = world.time
	return all_wounds

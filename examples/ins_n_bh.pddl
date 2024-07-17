(define 
(problem ins_n_bh)
(:domain dom_n)
(:objects
	; tracks
	; ================================ 
	track_51b - track
	track_52 - track
	track_53 - track
	track_54 - track
	track_55 - track
	track_56 - track
	track_57 - track
	track_58 - track
	track_59 - track
	track_60 - track
	track_61 - track
	track_62 - track
	track_104a - track
	track_entry - track

	; trains
	; ================================ 
	train_slt40 - train
	train_slt41 - train
	train_slt42 - train
	train_slt43 - train
	train_slt44 - train
	train_slt45 - train
	train_slt46 - train
	train_slt47 - train
)

(:init

	; metric
	; ================================ 
	(= (total-cost) 0)

	; track parking
	; ================================ 
	(parking_disallowed track_51b)
	(parking_disallowed track_61)
	(parking_disallowed track_62)
	(parking_disallowed track_104a)
	(parking_disallowed track_entry)

	; track servicing
	; ================================ 
	(service_allowed track_61)
	(service_allowed track_62)

	; track lengths
	; ================================ 
	(= (track_length track_51b) 80)
	(= (track_length track_52) 473)
	(= (track_length track_53) 421)
	(= (track_length track_54) 377)
	(= (track_length track_55) 380)
	(= (track_length track_56) 212)
	(= (track_length track_57) 192)
	(= (track_length track_58) 193)
	(= (track_length track_59) 271)
	(= (track_length track_60) 248)
	(= (track_length track_61) 80)
	(= (track_length track_62) 80)
	(= (track_length track_104a) 455)
	(= (track_length track_entry) 80)

	; track trains
	; ================================ 
	(= (num_trains_on_track track_51b) 0)
	(= (num_trains_on_track track_52) 0)
	(= (num_trains_on_track track_53) 0)
	(= (num_trains_on_track track_54) 0)
	(= (num_trains_on_track track_55) 0)
	(= (num_trains_on_track track_56) 0)
	(= (num_trains_on_track track_57) 0)
	(= (num_trains_on_track track_58) 0)
	(= (num_trains_on_track track_59) 0)
	(= (num_trains_on_track track_60) 0)
	(= (num_trains_on_track track_61) 0)
	(= (num_trains_on_track track_62) 0)
	(= (num_trains_on_track track_104a) 0)
	(= (num_trains_on_track track_entry) 8)

	; track spaces
	; ================================ 
	(= (train_order_on_track train_slt40) 1)
	(= (train_order_on_track train_slt41) 2)
	(= (train_order_on_track train_slt42) 3)
	(= (train_order_on_track train_slt43) 4)
	(= (train_order_on_track train_slt44) 5)
	(= (train_order_on_track train_slt45) 6)
	(= (train_order_on_track train_slt46) 7)
	(= (train_order_on_track train_slt47) 8)

	; inter track connections
	; ================================ 
	(tracks_linked track_51b track_59)
	(tracks_linked track_51b track_57)
	(tracks_linked track_51b track_55)
	(tracks_linked track_51b track_56)
	(tracks_linked track_51b track_53)
	(tracks_linked track_51b track_58)
	(tracks_linked track_51b track_52)
	(tracks_linked track_51b track_54)
	(tracks_linked track_60 track_59)
	(tracks_linked track_60 track_57)
	(tracks_linked track_60 track_56)
	(tracks_linked track_60 track_55)
	(tracks_linked track_60 track_54)
	(tracks_linked track_60 track_58)
	(tracks_linked track_60 track_52)
	(tracks_linked track_60 track_53)
	(tracks_linked track_61 track_58)
	(tracks_linked track_61 track_56)
	(tracks_linked track_61 track_59)
	(tracks_linked track_61 track_57)
	(tracks_linked track_62 track_58)
	(tracks_linked track_62 track_56)
	(tracks_linked track_62 track_59)
	(tracks_linked track_62 track_57)
	(tracks_linked track_104a track_51b)
	(tracks_linked track_52 track_entry)
	(tracks_linked track_53 track_entry)
	(tracks_linked track_54 track_entry)
	(tracks_linked track_55 track_entry)
	(tracks_linked track_56 track_entry)
	(tracks_linked track_57 track_entry)
	(tracks_linked track_58 track_entry)
	(tracks_linked track_59 track_entry)

	; train activity
	; ================================ 
	(is_active train_slt40)
	(is_active train_slt41)
	(is_active train_slt42)
	(is_active train_slt43)
	(is_active train_slt44)
	(is_active train_slt45)
	(is_active train_slt46)
	(is_active train_slt47)

	; train direction (default Aside)
	; ================================ 
	(is_direction_Aside train_slt40)
	(is_direction_Aside train_slt41)
	(is_direction_Aside train_slt42)
	(is_direction_Aside train_slt43)
	(is_direction_Aside train_slt44)
	(is_direction_Aside train_slt45)
	(is_direction_Aside train_slt46)
	(is_direction_Aside train_slt47)

	; train lengths
	; ================================ 
	(= (train_length train_slt40) 80)
	(= (train_length train_slt41) 80)
	(= (train_length train_slt42) 80)
	(= (train_length train_slt43) 80)
	(= (train_length train_slt44) 80)
	(= (train_length train_slt45) 80)
	(= (train_length train_slt46) 80)
	(= (train_length train_slt47) 80)

	; train locations
	; ================================ 
	(train_at train_slt40 track_entry)
	(train_at train_slt41 track_entry)
	(train_at train_slt42 track_entry)
	(train_at train_slt43 track_entry)
	(train_at train_slt44 track_entry)
	(train_at train_slt45 track_entry)
	(train_at train_slt46 track_entry)
	(train_at train_slt47 track_entry)


)

(:goal (and 

	; train goals
	; ================================ 
	(is_parking train_slt40)
	(was_serviced train_slt40)
	(is_parking train_slt41)
	(was_serviced train_slt41)
	(is_parking train_slt42)
	(was_serviced train_slt42)
	(is_parking train_slt43)
	(was_serviced train_slt43)
	(is_parking train_slt44)
	(was_serviced train_slt44)
	(is_parking train_slt45)
	(was_serviced train_slt45)
	(is_parking train_slt46)
	(was_serviced train_slt46)
	(is_parking train_slt47)
	(was_serviced train_slt47)

))

(:metric minimize (total-cost))
)
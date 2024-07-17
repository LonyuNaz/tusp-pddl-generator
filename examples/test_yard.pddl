(define 
(problem test_yard)
(:domain dom_n)
(:objects
	; tracks
	; ================================ 
	track_a_1 - track
	track_b_2 - track
	track_c_3 - track
	track_a_4 - track
	track_c_5 - track
	track_b_6 - track
	track_a_7 - track
	track_a_8 - track
	track_c_9 - track
	track_a_10 - track
	track_entry - track

	; trains
	; ================================ 
	train_1 - train
	train_2 - train
	train_3 - train
	train_4 - train
	train_5 - train
)

(:init

	; metric
	; ================================ 
	(= (total-cost) 0)

	; track parking
	; ================================ 
	(parking_disallowed track_a_1)
	(parking_disallowed track_b_2)
	(parking_disallowed track_a_4)
	(parking_disallowed track_b_6)
	(parking_disallowed track_a_7)
	(parking_disallowed track_a_8)
	(parking_disallowed track_a_10)
	(parking_disallowed track_entry)

	; track servicing
	; ================================ 
	(service_allowed track_b_2)
	(service_allowed track_b_6)

	; track lengths
	; ================================ 
	(= (track_length track_a_1) 80)
	(= (track_length track_b_2) 80)
	(= (track_length track_c_3) 80)
	(= (track_length track_a_4) 80)
	(= (track_length track_c_5) 80)
	(= (track_length track_b_6) 80)
	(= (track_length track_a_7) 80)
	(= (track_length track_a_8) 80)
	(= (track_length track_c_9) 80)
	(= (track_length track_a_10) 80)
	(= (track_length track_entry) 80)

	; track trains
	; ================================ 
	(= (num_trains_on_track track_a_1) 0)
	(= (num_trains_on_track track_b_2) 0)
	(= (num_trains_on_track track_c_3) 0)
	(= (num_trains_on_track track_a_4) 0)
	(= (num_trains_on_track track_c_5) 0)
	(= (num_trains_on_track track_b_6) 0)
	(= (num_trains_on_track track_a_7) 0)
	(= (num_trains_on_track track_a_8) 0)
	(= (num_trains_on_track track_c_9) 0)
	(= (num_trains_on_track track_a_10) 0)
	(= (num_trains_on_track track_entry) 5)

	; track spaces
	; ================================ 
	(= (train_order_on_track train_1) 1)
	(= (train_order_on_track train_2) 2)
	(= (train_order_on_track train_3) 3)
	(= (train_order_on_track train_4) 4)
	(= (train_order_on_track train_5) 5)

	; inter track connections
	; ================================ 
	(tracks_linked track_a_1 track_b_2)
	(tracks_linked track_a_4 track_b_6)
	(tracks_linked track_a_7 track_b_6)
	(tracks_linked track_a_8 track_b_2)
	(tracks_linked track_a_10 track_b_6)
	(tracks_linked track_b_2 track_c_3)
	(tracks_linked track_b_6 track_c_9)
	(tracks_linked track_a_1 track_b_6)
	(tracks_linked track_a_7 track_b_2)
	(tracks_linked track_a_10 track_b_2)
	(tracks_linked track_b_6 track_c_3)
	(tracks_linked track_a_4 track_b_2)
	(tracks_linked track_a_8 track_b_6)
	(tracks_linked track_entry track_a_4)
	(tracks_linked track_entry track_a_10)

	; train activity
	; ================================ 
	(is_active train_1)
	(is_active train_2)
	(is_active train_3)
	(is_active train_4)
	(is_active train_5)

	; train direction (default Aside)
	; ================================ 
	(is_direction_Aside train_1)
	(is_direction_Aside train_2)
	(is_direction_Aside train_3)
	(is_direction_Aside train_4)
	(is_direction_Aside train_5)

	; train lengths
	; ================================ 
	(= (train_length train_1) 80)
	(= (train_length train_2) 80)
	(= (train_length train_3) 80)
	(= (train_length train_4) 80)
	(= (train_length train_5) 80)

	; train locations
	; ================================ 
	(train_at train_1 track_entry)
	(train_at train_2 track_entry)
	(train_at train_3 track_entry)
	(train_at train_4 track_entry)
	(train_at train_5 track_entry)


)

(:goal (and 

	; train goals
	; ================================ 
	(is_parking train_1)
	(was_serviced train_1)
	(is_parking train_2)
	(was_serviced train_2)
	(is_parking train_3)
	(was_serviced train_3)
	(is_parking train_4)
	(was_serviced train_4)
	(is_parking train_5)
	(was_serviced train_5)

))

(:metric minimize (total-cost))
)
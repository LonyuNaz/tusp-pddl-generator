(define 
(problem test_yard)
(:domain dom_n)
(:objects
	; tracks
	; ================================ 
	track_a_1 - track
	track_a_2 - track
	track_a_3 - track
	track_a_4 - track
	track_a_5 - track
	track_a_6 - track
	track_b_1 - track
	track_c_1 - track
	track_c_2 - track
	track_c_3 - track
	track_c_4 - track
	track_c_5 - track
	track_c_6 - track
	track_c_7 - track
	track_d_1 - track
	track_d_2 - track
	track_d_3 - track
	track_d_4 - track
	track_d_5 - track
	track_d_6 - track
	track_entry - track

	; trains
	; ================================ 
	train_0 - train
	train_1 - train
)

(:init

	; metric
	; ================================ 
	(= (total-cost) 0)

	; track parking
	; ================================ 
	(parking_disallowed track_a_1)
	(parking_disallowed track_a_2)
	(parking_disallowed track_a_3)
	(parking_disallowed track_a_4)
	(parking_disallowed track_a_5)
	(parking_disallowed track_a_6)
	(parking_disallowed track_b_1)
	(parking_disallowed track_c_1)
	(parking_disallowed track_c_2)
	(parking_disallowed track_c_3)
	(parking_disallowed track_c_4)
	(parking_disallowed track_c_5)
	(parking_disallowed track_c_6)
	(parking_disallowed track_c_7)
	(parking_disallowed track_entry)

	; track servicing
	; ================================ 
	(service_allowed track_b_1)

	; track lengths
	; ================================ 
	(= (track_length track_a_1) 80)
	(= (track_length track_a_2) 80)
	(= (track_length track_a_3) 80)
	(= (track_length track_a_4) 80)
	(= (track_length track_a_5) 80)
	(= (track_length track_a_6) 80)
	(= (track_length track_b_1) 80)
	(= (track_length track_c_1) 80)
	(= (track_length track_c_2) 80)
	(= (track_length track_c_3) 80)
	(= (track_length track_c_4) 80)
	(= (track_length track_c_5) 80)
	(= (track_length track_c_6) 80)
	(= (track_length track_c_7) 80)
	(= (track_length track_d_1) 80)
	(= (track_length track_d_2) 80)
	(= (track_length track_d_3) 80)
	(= (track_length track_d_4) 80)
	(= (track_length track_d_5) 80)
	(= (track_length track_d_6) 80)
	(= (track_length track_entry) 80)

	; track trains
	; ================================ 
	(= (num_trains_on_track track_a_1) 0)
	(= (num_trains_on_track track_a_2) 0)
	(= (num_trains_on_track track_a_3) 0)
	(= (num_trains_on_track track_a_4) 0)
	(= (num_trains_on_track track_a_5) 0)
	(= (num_trains_on_track track_a_6) 0)
	(= (num_trains_on_track track_b_1) 0)
	(= (num_trains_on_track track_c_1) 0)
	(= (num_trains_on_track track_c_2) 0)
	(= (num_trains_on_track track_c_3) 0)
	(= (num_trains_on_track track_c_4) 0)
	(= (num_trains_on_track track_c_5) 0)
	(= (num_trains_on_track track_c_6) 0)
	(= (num_trains_on_track track_c_7) 0)
	(= (num_trains_on_track track_d_1) 0)
	(= (num_trains_on_track track_d_2) 0)
	(= (num_trains_on_track track_d_3) 0)
	(= (num_trains_on_track track_d_4) 0)
	(= (num_trains_on_track track_d_5) 0)
	(= (num_trains_on_track track_d_6) 0)
	(= (num_trains_on_track track_entry) 2)

	; track spaces
	; ================================ 
	(= (train_order_on_track train_0) 1)
	(= (train_order_on_track train_1) 2)

	; inter track connections
	; ================================ 
	(tracks_linked track_a_1 track_b_1)
	(tracks_linked track_a_2 track_b_1)
	(tracks_linked track_a_3 track_b_1)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_a_5 track_b_1)
	(tracks_linked track_a_6 track_b_1)
	(tracks_linked track_b_1 track_c_1)
	(tracks_linked track_c_1 track_d_4)
	(tracks_linked track_c_2 track_d_4)
	(tracks_linked track_c_3 track_d_6)
	(tracks_linked track_c_4 track_d_2)
	(tracks_linked track_c_5 track_d_5)
	(tracks_linked track_c_6 track_d_1)
	(tracks_linked track_c_7 track_d_4)
	(tracks_linked track_c_1 track_d_5)
	(tracks_linked track_b_1 track_c_2)
	(tracks_linked track_b_1 track_c_4)
	(tracks_linked track_c_7 track_d_3)
	(tracks_linked track_a_6 track_b_1)
	(tracks_linked track_a_3 track_b_1)
	(tracks_linked track_c_4 track_d_6)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_c_2 track_d_6)
	(tracks_linked track_c_4 track_d_3)
	(tracks_linked track_a_3 track_b_1)
	(tracks_linked track_a_2 track_b_1)
	(tracks_linked track_c_1 track_d_5)
	(tracks_linked track_a_1 track_b_1)
	(tracks_linked track_a_2 track_b_1)
	(tracks_linked track_b_1 track_c_5)
	(tracks_linked track_a_5 track_b_1)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_c_4 track_d_4)
	(tracks_linked track_c_6 track_d_2)
	(tracks_linked track_a_6 track_b_1)
	(tracks_linked track_a_2 track_b_1)
	(tracks_linked track_c_2 track_d_4)
	(tracks_linked track_c_7 track_d_4)
	(tracks_linked track_c_5 track_d_3)
	(tracks_linked track_c_1 track_d_5)
	(tracks_linked track_c_6 track_d_4)
	(tracks_linked track_c_6 track_d_2)
	(tracks_linked track_b_1 track_c_5)
	(tracks_linked track_c_5 track_d_3)
	(tracks_linked track_a_1 track_b_1)
	(tracks_linked track_a_3 track_b_1)
	(tracks_linked track_c_6 track_d_6)
	(tracks_linked track_c_4 track_d_2)
	(tracks_linked track_c_5 track_d_4)
	(tracks_linked track_c_2 track_d_5)
	(tracks_linked track_c_2 track_d_1)
	(tracks_linked track_c_5 track_d_2)
	(tracks_linked track_c_1 track_d_2)
	(tracks_linked track_c_1 track_d_1)
	(tracks_linked track_c_7 track_d_1)
	(tracks_linked track_c_6 track_d_2)
	(tracks_linked track_c_2 track_d_3)
	(tracks_linked track_c_3 track_d_4)
	(tracks_linked track_c_6 track_d_6)
	(tracks_linked track_a_2 track_b_1)
	(tracks_linked track_a_5 track_b_1)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_a_5 track_b_1)
	(tracks_linked track_c_2 track_d_4)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_a_3 track_b_1)
	(tracks_linked track_c_3 track_d_1)
	(tracks_linked track_c_7 track_d_4)
	(tracks_linked track_c_7 track_d_5)
	(tracks_linked track_b_1 track_c_6)
	(tracks_linked track_b_1 track_c_1)
	(tracks_linked track_c_3 track_d_2)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_a_6 track_b_1)
	(tracks_linked track_c_6 track_d_2)
	(tracks_linked track_a_4 track_b_1)
	(tracks_linked track_c_7 track_d_5)
	(tracks_linked track_c_3 track_d_4)
	(tracks_linked track_a_6 track_b_1)
	(tracks_linked track_c_1 track_d_1)
	(tracks_linked track_entry track_a_2)
	(tracks_linked track_entry track_a_6)
	(tracks_linked track_entry track_a_4)
	(tracks_linked track_entry track_a_4)
	(tracks_linked track_entry track_a_4)
	(tracks_linked track_entry track_a_2)
	(tracks_linked track_entry track_a_5)
	(tracks_linked track_entry track_a_5)
	(tracks_linked track_entry track_a_3)
	(tracks_linked track_entry track_a_1)
	(tracks_linked track_entry track_a_2)

	; train activity
	; ================================ 
	(is_active train_0)
	(is_active train_1)

	; train direction (default Aside)
	; ================================ 
	(is_direction_Aside train_0)
	(is_direction_Aside train_1)

	; train lengths
	; ================================ 
	(= (train_length train_0) 80)
	(= (train_length train_1) 80)

	; train locations
	; ================================ 
	(train_at train_0 track_entry)
	(train_at train_1 track_entry)


)

(:goal (and 

	; train goals
	; ================================ 
	(is_parking train_0)
	(was_serviced train_0)
	(is_parking train_1)
	(was_serviced train_1)

))

(:metric minimize (total-cost))
)
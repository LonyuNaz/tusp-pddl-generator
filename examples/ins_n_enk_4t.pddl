(define 
(problem ins_n_enk)
(:domain dom_n)
(:objects
	; tracks
	; ================================ 
	track_t_401 - track
	track_t_402 - track
	track_t_403 - track
	track_t_404 - track
	track_t_405 - track
	track_t_406 - track
	track_t_407 - track
	track_entry - track

	; trains
	; ================================ 
	train_ddz_1 - train
	train_ddz_2 - train
	train_ddz_3 - train
	train_ddz_4 - train
)

(:init

	; metric
	; ================================ 
	(= (cost) 0)

	; track parking
	; ================================ 
	(parking_disallowed track_entry)

	; track servicing
	; ================================ 

	; track lengths
	; ================================ 
	(= (track_length track_t_401) 460)
	(= (track_length track_t_402) 460)
	(= (track_length track_t_403) 460)
	(= (track_length track_t_404) 630)
	(= (track_length track_t_405) 670)
	(= (track_length track_t_406) 670)
	(= (track_length track_t_407) 570)
	(= (track_length track_entry) 0)

	; track trains
	; ================================ 
	(= (num_trains_on_track track_t_401) 0)
	(= (num_trains_on_track track_t_402) 0)
	(= (num_trains_on_track track_t_403) 0)
	(= (num_trains_on_track track_t_404) 0)
	(= (num_trains_on_track track_t_405) 0)
	(= (num_trains_on_track track_t_406) 0)
	(= (num_trains_on_track track_t_407) 0)
	(= (num_trains_on_track track_entry) 4)

	; track spaces
	; ================================ 
	(= (train_order_on_track train_ddz_1) 1)
	(= (train_order_on_track train_ddz_2) 2)
	(= (train_order_on_track train_ddz_3) 3)
	(= (train_order_on_track train_ddz_4) 4)

	; inter track connections
	; ================================ 
	(tracks_linked track_t_404 track_t_401)
	(tracks_linked track_t_404 track_t_402)
	(tracks_linked track_t_404 track_t_403)
	(tracks_linked track_t_405 track_t_401)
	(tracks_linked track_t_405 track_t_402)
	(tracks_linked track_t_405 track_t_403)
	(tracks_linked track_t_406 track_t_401)
	(tracks_linked track_t_406 track_t_402)
	(tracks_linked track_t_406 track_t_403)
	(tracks_linked track_t_407 track_t_401)
	(tracks_linked track_t_407 track_t_402)
	(tracks_linked track_t_407 track_t_403)
	(tracks_linked track_entry track_t_401)
	(tracks_linked track_entry track_t_402)
	(tracks_linked track_entry track_t_403)

	; train activity
	; ================================ 
	(is_active train_ddz_1)
	(is_active train_ddz_2)
	(is_active train_ddz_3)
	(is_active train_ddz_4)

	; train direction (default Aside)
	; ================================ 
	(is_direction_Aside train_ddz_1)
	(is_direction_Aside train_ddz_2)
	(is_direction_Aside train_ddz_3)
	(is_direction_Aside train_ddz_4)

	; train lengths
	; ================================ 
	(= (train_length train_ddz_1) 160)
	(= (train_length train_ddz_2) 160)
	(= (train_length train_ddz_3) 160)
	(= (train_length train_ddz_4) 160)

	; train locations
	; ================================ 
	(train_at train_ddz_1 track_entry)
	(train_at train_ddz_2 track_entry)
	(train_at train_ddz_3 track_entry)
	(train_at train_ddz_4 track_entry)

	(= (train_distance_to_end_of_track train_ddz_1) 0)
	(= (train_distance_to_end_of_track train_ddz_2) 160)
	(= (train_distance_to_end_of_track train_ddz_3) 320)
	(= (train_distance_to_end_of_track train_ddz_4) 480)

)

(:goal (and 

	; train parking
	; ================================ 
	(is_parking train_ddz_1)
	(is_parking train_ddz_2)
	(is_parking train_ddz_3)
	(is_parking train_ddz_4)

))

(:metric minimize (cost))
)
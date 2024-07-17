;Header and description

(define (domain dom_nt_1)

;remove requirements that are not needed
(:requirements 
    :fluents 
    :durative-actions
    :typing 
)

(:types 
    train - object
    track - object
    driver - object
)

; un-comment following line if constants are needed
;(:constants )

(:predicates ;todo: define predicates here
    ; driver
    (idle ?driver - driver)

    ; driver & train
    (driving_train ?driver - driver ?train - train)

    ; train
    (is_active ?train - train)
    (train_operated ?train - train)
    (train_unoperated ?train - train)
    (is_available ?train - train)
    (is_direction_Aside ?train - train)
    (is_direction_Bside ?train - train)
    (is_parking ?train - train)
    (has_parked ?train - train)

    ; train and track
    (train_at ?train - train ?track - track)    

    ; track
    (parking_allowed ?track - track)
    (tracks_linked ?trackLeft - track ?trackRight - track)
)


(:functions 
    ; train
    (train_length ?train - train)
    (train_distance_to_end_of_track ?train - train)

    ; track
    (track_length ?track - track)
    (stack_Aside_distance_to_end_of_track ?track - track)
    (stack_Bside_distance_to_end_of_track ?track - track)
    (num_trains_on_track ?track - track)
)


(:durative-action enter_train
    :parameters (
        ?driver - driver
        ?train - train
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (idle ?driver)
        ))
        (over all (and 
            (is_active ?train)
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
            (not (idle ?driver))
        ))
        (at end (and 
            (is_available ?train)

            (train_operated ?train)
            (not (train_unoperated ?train))

            (driving_train ?driver ?train)
        ))
    )
)

(:durative-action exit_train
    :parameters (
        ?driver - driver
        ?train - train
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (driving_train ?driver ?train)
        ))
        (over all (and 
            (is_active ?train)
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
            (not (driving_train ?driver ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (train_operated ?train))
            (train_unoperated ?train)

            (idle ?driver)
        ))
    )
)

(:durative-action turn_to_Aside
    :parameters (
        ?train - train
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (is_direction_Bside ?train)
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (is_direction_Bside ?train))
            (is_direction_Aside ?train)
        ))
    )
)

(:durative-action turn_to_Bside
    :parameters (
        ?train - train
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (is_direction_Aside ?train)
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (is_direction_Aside ?train))
            (is_direction_Bside ?train)
        ))
    )
)

(:durative-action start_parking_at
    :parameters (
        ?train - train
        ?track - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (over all (and 
            (is_available ?train)    
            (is_active ?train)
            (train_at ?train ?track)
            (parking_allowed ?track)       
        ))
    )
    :effect (and 
        (at start (and 
        ))
        (at end (and 
            (not (is_available ?train))
            (is_parking ?train)
        ))
    )
)

(:durative-action stop_parking_at
    :parameters (
        ?train - train
    )
    :duration (= ?duration 100)
    :condition (and 
        (at start (and 
            (is_available ?train)    
        ))
        (over all (and 
            (is_parking ?train)
        ))
    )
    :effect (and 
        (at end (and 
            (is_available ?train)
            (not (is_parking ?train))
            (has_parked ?train)
        ))
    )
)




(:durative-action move_Aside_onto_empty_track
    :parameters (
        ?train - train
        ?trackLeft - track
        ?trackRight - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (train_at ?train ?trackLeft)

            ; we must be at the front of the Astack queue
            (= (train_distance_to_end_of_track ?train) (stack_Aside_distance_to_end_of_track ?trackLeft))

            ; the other track must be empty (otherwise move aside onto occupied track)
            (= (num_trains_on_track ?trackRight) 0)
            ; there must be enough space for us to move into
            (>=
                (track_length ?trackRight)
                (train_length ?train)
            )
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
            (is_direction_Aside ?train)
            (tracks_linked ?trackLeft ?trackRight)   
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (train_at ?train ?trackLeft))
            (train_at ?train ?trackRight)

            (increase (stack_Aside_distance_to_end_of_track ?trackLeft) (train_length ?train))
            (decrease (num_trains_on_track ?trackLeft) 1)

            (assign (stack_Aside_distance_to_end_of_track ?trackRight) 0)
            (assign (stack_Bside_distance_to_end_of_track ?trackRight) (train_length ?train))
            (assign (train_distance_to_end_of_track ?train) 0)
            (increase (num_trains_on_track ?trackRight) 1)
        ))
    )
)

(:durative-action move_Aside_onto_occupied_track
    :parameters (
        ?train - train
        ?trackLeft - track
        ?trackRight - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (train_at ?train ?trackLeft)

            ; we must be at the front of the Astack queue
            (= (train_distance_to_end_of_track ?train) (stack_Aside_distance_to_end_of_track ?trackLeft))

            ; the other track must be occupied (otherwise move aside onto empty track)
            (> (num_trains_on_track ?trackRight) 0)
            
            ; there must be enough space for us to move into
            (>=
                (-
                    (track_length ?trackRight)
                    (stack_Bside_distance_to_end_of_track ?trackRight)
                )
                (train_length ?train)
            )
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
            (is_direction_Aside ?train)
            (tracks_linked ?trackLeft ?trackRight)   
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (train_at ?train ?trackLeft))
            (train_at ?train ?trackRight)

            (increase (stack_Aside_distance_to_end_of_track ?trackLeft) (train_length ?train))
            (decrease (num_trains_on_track ?trackLeft) 1)

            (assign (train_distance_to_end_of_track ?train) (stack_Bside_distance_to_end_of_track ?trackRight))
            (increase (stack_Bside_distance_to_end_of_track ?trackRight) (train_length ?train))
            (increase (num_trains_on_track ?trackRight) 1)
        ))
    )
)

(:durative-action move_Bside_onto_empty_track
    :parameters (
        ?train - train
        ?trackRight - track
        ?trackLeft - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (train_at ?train ?trackRight)

            ; we must be at the front of the queue when looking at the Bside
            (= 
                (+
                    (train_distance_to_end_of_track ?train) 
                    (train_length ?train)
                )
                (stack_Bside_distance_to_end_of_track ?trackRight)                
            )

            ; the other track must be empty (otherwise move aside onto occupied track)
            (= (num_trains_on_track ?trackLeft) 0)

            ; there must be enough space for us to move into
            (>=
                (track_length ?trackLeft)
                (train_length ?train)
            )
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
            (is_direction_Bside ?train)
            (tracks_linked ?trackLeft ?trackRight)   
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (train_at ?train ?trackRight))
            (train_at ?train ?trackLeft)

            (decrease (stack_Bside_distance_to_end_of_track ?trackRight) (train_length ?train))
            (decrease (num_trains_on_track ?trackRight) 1)

            (assign (stack_Aside_distance_to_end_of_track ?trackLeft) (- (track_length ?trackLeft) (train_length ?train)))
            (assign (stack_Bside_distance_to_end_of_track ?trackLeft) (track_length ?trackLeft))
            (assign (train_distance_to_end_of_track ?train) (stack_Aside_distance_to_end_of_track ?trackLeft))
            (increase (num_trains_on_track ?trackLeft) 1)
            
        ))
    )
)

(:durative-action move_Bside_onto_occupied_track
    :parameters (
        ?train - train
        ?trackRight - track
        ?trackLeft - track
    )
    :duration (= ?duration 1)
    :condition (and 
        (at start (and 
            (is_available ?train)
            (train_at ?train ?trackRight)

            ; we must be at the front of the queue when looking at the Bside
            (= 
                (+
                    (train_distance_to_end_of_track ?train) 
                    (train_length ?train)
                )
                (stack_Bside_distance_to_end_of_track ?trackRight)                
            )

            ; the other track must be empty (otherwise move aside onto occupied track)
            (> (num_trains_on_track ?trackLeft) 0)

            ; there must be enough space for us to move into
            (>=
                (stack_Aside_distance_to_end_of_track ?trackLeft)
                (train_length ?train)
            )
        ))
        (over all (and 
            (is_active ?train)
            (train_operated ?train)
            (is_direction_Bside ?train)
            (tracks_linked ?trackLeft ?trackRight)   
        ))
    )
    :effect (and 
        (at start (and 
            (not (is_available ?train))
        ))
        (at end (and 
            (is_available ?train)

            (not (train_at ?train ?trackRight))
            (train_at ?train ?trackLeft)

            (decrease (stack_Bside_distance_to_end_of_track ?trackRight) (train_length ?train))
            (decrease (num_trains_on_track ?trackRight) 1)

            (decrease (stack_Aside_distance_to_end_of_track ?trackLeft) (train_length ?train))
            (assign (train_distance_to_end_of_track ?train) (stack_Aside_distance_to_end_of_track ?trackLeft))
            (increase (num_trains_on_track ?trackLeft) 1)
            
        ))
    )
)




)
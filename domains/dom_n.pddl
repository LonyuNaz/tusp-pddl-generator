(define (domain dom_n)

(:requirements 
    :negative-preconditions 
    :typing 
    :fluents
    :equality
    :conditional-effects
)

(:types 
    track - object
    train - object
)

(:predicates 
    ; train status
    (is_active ?train - train)
    (is_parking ?train - train)
    (has_parked ?train - train)
    (was_serviced ?train - train)

    ; train coordinates
    (train_at ?train - train ?track - track)

    ; track connections
    (tracks_linked ?trackLeft - track ?trackRight - track)
    
    ; track service
    (parking_disallowed ?track - track)
    (service_allowed ?track - track)
)

(:functions
    ; cost
    (cost)

    ; lengths
    (train_length ?train - train)
    (track_length ?track - track)

    ; train location
    (train_distance_to_end_of_track ?train - train)

    ; space on track
    (track_Bside_occupied_length ?track - track)
    (track_Aside_occupied_length ?track - track)
)

(:action start_parking
    :parameters (
        ?train - train
        ?track - track
    )
    :precondition (and 
        (is_active ?train)
        (not (is_parking ?train))
        (not (has_parked ?train))

        (train_at ?train ?track)
        (not (parking_disallowed ?track))
    )
    :effect (and 
        (increase (cost) 1)
        (is_parking ?train)
    )
)

(:action stop_parking
    :parameters (
        ?train - train
    )
    :precondition (and 
        (is_parking ?train)
    )
    :effect (and 
        (increase (cost) 1)
        (not (is_parking ?train))
        (has_parked ?train)
    )
)

(:action service_train
    :parameters (
        ?train - train
        ?track - track
    )
    :precondition (and 
        (train_at ?train ?track)
        (service_allowed ?track)
    )
    :effect (and 
        (increase (cost) 1)
        (was_serviced ?train)
    )
)


(:action move_Aside_across_tracks
    :parameters (
        ?train - train
        ?trackLeft - track
        ?trackRight - track
    )
    :precondition (and 
        (is_active ?train)
        (not (is_parking ?train))

        (train_at ?train ?trackLeft)
        (tracks_linked ?trackLeft ?trackRight)

        ; there is enough space to join the stack on the Aside
        (>= 
            (-
                (track_length ?trackRight)
                (track_Aside_occupied_length ?trackRight)
            ) 
            (train_length ?train))

        ; there is no stack of trains on the Bside
        (= (track_Bside_occupied_length ?trackRight) 0)

        ; there is not train blocking us
        (not (exists (?otherTrain - train) 
            (and
                (not (= ?otherTrain ?train))
                (is_active ?otherTrain)
                (train_at ?otherTrain ?trackLeft)
                ; the Aside of the other train must be further away from the Aside of the track
                ; than us
                (<
                    (train_distance_to_end_of_track ?otherTrain)
                    (train_distance_to_end_of_track ?train)
                )
            )
        ))

    )
    :effect (and 
        (increase (cost) 1)
        (not (train_at ?train ?trackLeft))
        (train_at ?train ?trackRight)
        (when 
            (= 
                (track_Bside_occupied_length ?trackLeft) 
                (-
                    (track_length ?trackRight)
                    (train_distance_to_end_of_track ?train) 
                ) 
            )
            (decrease  (track_Bside_occupied_length ?trackLeft) (train_length ?train))
        )
        (when 
            (not (exists (?otherTrain - train) (train_at ?otherTrain ?trackLeft)))
            (and
                (assign (track_Aside_occupied_length ?trackLeft) 0)
                (assign (track_Bside_occupied_length ?trackLeft) 0)
            )
        )
        (assign 
            (train_distance_to_end_of_track ?train)
            (track_Aside_occupied_length ?trackRight)  
        )
        (increase (track_Aside_occupied_length ?trackRight) (train_length ?train))
    )
)

(:action move_Bside_across_tracks
    :parameters (
        ?train - train
        ?trackRight - track
        ?trackLeft - track
    )
    :precondition (and 
        (is_active ?train)
        (not (is_parking ?train))

        (train_at ?train ?trackRight)
        (tracks_linked ?trackLeft ?trackRight)

        ; there is enough space to join the stack on the Bside
        (>= 
            (-
                (track_length ?trackLeft)
                (track_Bside_occupied_length ?trackLeft)
            ) 
            (train_length ?train))

        ; there is no stack of trains on the Bside
        (= (track_Aside_occupied_length ?trackLeft) 0)

        (>= (track_length ?trackLeft) (train_length ?train))

        ; there is not train blocking us
        (not (exists (?otherTrain - train) 
            (and
                (not (= ?otherTrain ?train))
                (is_active ?otherTrain)
                (train_at ?otherTrain ?trackRight)
                ; the Aside of the other train must be closer to the Aside of the track
                ; than us
                (>
                    (train_distance_to_end_of_track ?otherTrain)
                    (train_distance_to_end_of_track ?train)
                )
            )
        ))
    )
    :effect (and 
        (increase (cost) 1)
        (not (train_at ?train ?trackRight))
        (train_at ?train ?trackLeft)
        (when 
            (= 
                (track_Aside_occupied_length ?trackRight) 
                (+ 
                    (train_distance_to_end_of_track ?train) 
                    (train_length ?train)
                )
            
            )
            (decrease (track_Aside_occupied_length ?trackRight) (train_length ?train))
        )
        (when 
            (not (exists (?otherTrain - train) (train_at ?otherTrain ?trackRight)))
            (and
                (assign (track_Aside_occupied_length ?trackRight) 0)
                (assign (track_Bside_occupied_length ?trackRight) 0)
            )
        )
        (assign 
            (train_distance_to_end_of_track ?train)
            (+
                (track_Bside_occupied_length ?trackLeft)    
                (train_length ?train)
            )
        )
        (increase (track_Bside_occupied_length ?trackLeft) (train_length ?train))
    )
)




)
(define (domain dom_n_9)

(:requirements 
    :negative-preconditions 
    :disjunctive-preconditions
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
    (is_direction_Aside ?train - train)

    ; train coordinates
    (train_at ?train - train ?track - track)

    ; track connections
    (tracks_linked ?trackLeft - track ?trackRight - track)
    
    ; track service
    (parking_disallowed ?track - track)
)

(:functions
    ; cost
    (cost)

    ; lengths
    (train_length ?train - train)
    (track_length ?track - track)

    ; train config
    (train_order_on_track ?train - train)
    
    ; track config
    (num_trains_on_track ?track - track)

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

(:action move_Aside
    :parameters (
        ?train - train
        ?trackFrom - track
        ?trackTo - track
    )
    :precondition (and 
        (is_active ?train)
        (train_at ?train ?trackFrom)

        (tracks_linked ?trackFrom ?trackTo)

        (>= (track_length ?trackTo) (train_length ?train))

        (= (train_order_on_track ?train) 1)

    )
    :effect (and 
        (increase (cost) 1) 
        (when (not (is_direction_Aside ?train)) 
            (increase (cost) 10) 
        )
        (is_direction_Aside ?train)

        (not (train_at ?train ?trackFrom))
        (train_at ?train ?trackTo)

        (forall (?otherTrain - train) 
            (when (train_at ?otherTrain ?trackFrom)
                (decrease (train_order_on_track) 1)
            )
        )
        (increase (track_length ?trackFrom) (train_length ?train))
        (decrease (track_length ?trackTo) (train_length ?train))
        (decrease (num_trains_on_track ?trackFrom) 1)
        (increase (num_trains_on_track ?trackTo) 1)
        (assign (train_order_on_track ?train) (num_trains_on_track ?trackTo))
    )
)

(:action move_Bside
    :parameters (
        ?train - train
        ?trackFrom - track
        ?trackTo - track
    )
    :precondition (and 
        (is_active ?train)
        (train_at ?train ?trackFrom)

        (tracks_linked ?trackTo ?trackFrom)

        (>= (track_length ?trackTo) (train_length ?train))

        (= (train_order_on_track ?train) (num_trains_on_track ?trackFrom))

    )
    :effect (and 
        (increase (cost) 1) 
        (when (is_direction_Aside ?train)
            (increase (cost) 10) 
        )
        (not (is_direction_Aside ?train))

        (not (train_at ?train ?trackFrom))
        (train_at ?train ?trackTo)

        (forall (?otherTrain - train) 
            (when (train_at ?otherTrain ?trackTo)
                (increase (train_order_on_track) 1)
            )
        )
        (increase (track_length ?trackFrom) (train_length ?train))
        (decrease (track_length ?trackTo) (train_length ?train))
        (decrease (num_trains_on_track ?trackFrom) 1)
        (increase (num_trains_on_track ?trackTo) 1)
        (assign (train_order_on_track ?train) 1)
    )
)



)
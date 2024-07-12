(define (domain dom_n)

(:requirements 
    :negative-preconditions 
    :disjunctive-preconditions
    :typing 
    :fluents
    :equality
    :conditional-effects
    :action-costs
)

(:types 
    track - object
    train - object
)

(:predicates 
    ; train status
    (is_active ?train - train)
    (parkable ?train - train)
    (servicable ?train - train)
    (is_parking ?train - train)
    (has_parked ?train - train)
    (was_serviced ?train - train)
    (is_direction_Aside ?train - train)

    ; train coordinates
    (train_at ?train - train ?track - track)
    (block ?track - track)
    (block_mutex_holder ?track - track ?train - train)
    (is_entry ?track - track)

    ; track connections
    (tracks_linked ?trackLeft - track ?trackRight - track)
    
    ; track service
    (parking_disallowed ?track - track)
    (service_allowed ?track - track)
)

(:functions
    ; total-cost
    (total-cost)

    ; lengths
    (train_length ?train - train)
    (track_length ?track - track)

    ; train config
    (train_order_on_track ?train - train)
    
    ; track config
    (num_trains_on_track ?track - track)

)

; (:action exit_track
;     :parameters (
;         ?train - train
;         ?track - track
;     )
;     :precondition (and 
;         (train_at ?train ?track)
;         (is_active ?train)
;         (is_entry ?track)
;         (= (num_trains_on_track ?track) 1)
;     )
;     :effect (and 
;         (not (is_active ?train))
;         (forall (?tr - track) 
;             (when (block_mutex_holder ?tr ?train) (not (block ?tr)))
;         )
;         (decrease (num_trains_on_track ?track) 1)
;     )
; )


(:action service_train
    :parameters (
        ?train - train
    )
    :precondition (and 
        (is_active ?train)
        (servicable ?train)
        (not (is_parking ?train))
        (not (was_serviced ?train))
    )
    :effect (and 
        (increase (total-cost) 1)
        (was_serviced ?train)
        (forall (?tr - track) 
            (when (block_mutex_holder ?tr ?train) (not (block ?tr)))
        )
    )
)

(:action start_parking
    :parameters (
        ?train - train
    )
    :precondition (and 
        (is_active ?train)
        (parkable ?train)
        (not (is_parking ?train))
        (not (has_parked ?train))
    )
    :effect (and 
        (decrease (total-cost) 10)
        (is_parking ?train)
        (forall (?tr - track) 
            (when (block_mutex_holder ?tr ?train) (not (block ?tr)))
        )
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
        (increase (total-cost) 100)
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
        (not (is_parking ?train))
        (train_at ?train ?trackFrom)

        (not (block ?trackTo))
        (not (block ?trackFrom))

        (tracks_linked ?trackFrom ?trackTo)

        (>= (track_length ?trackTo) (train_length ?train))

        (= (train_order_on_track ?train) 1)

    )
    :effect (and 
        (increase (total-cost) 2) 
        (when (not (is_direction_Aside ?train)) 
            (increase (total-cost) 11) 
        )
        (is_direction_Aside ?train)

        (not (train_at ?train ?trackFrom))
        (train_at ?train ?trackTo)

        (forall (?otherTrain - train) 
            (when 
                (and (not (= ?otherTrain ?train)) (train_at ?otherTrain ?trackFrom))
                (decrease (train_order_on_track ?otherTrain) 1)
            )
        )
        (increase (track_length ?trackFrom) (train_length ?train))
        (decrease (track_length ?trackTo) (train_length ?train))
        
        (assign (train_order_on_track ?train) (+ (num_trains_on_track ?trackTo) 1))

        (decrease (num_trains_on_track ?trackFrom) 1)
        (increase (num_trains_on_track ?trackTo) 1)

        (block ?trackFrom)
        (block_mutex_holder ?trackFrom ?train)

        (not (servicable ?train))
        (when (service_allowed ?trackTo) (servicable ?train))

        (not (parkable ?train))
        (when (not (parking_disallowed ?trackTo)) (parkable ?train))
    )
)

; (:action move_Aside2
;     :parameters (
;         ?train - train
;         ?trackFrom - track
;         ?trackMiddle - track
;         ?trackTo - track
;     )
;     :precondition (and 
;         (is_active ?train)
;         (not (is_parking ?train))
;         (train_at ?train ?trackFrom)

;         (not (block ?trackTo))
;         (not (block ?trackMiddle))
;         (not (block ?trackFrom))

;         (tracks_linked ?trackFrom ?trackMiddle)
;         (= (num_trains_on_track ?trackMiddle) 0)
;         (tracks_linked ?trackMiddle ?trackTo)

;         (>= (track_length ?trackTo) (train_length ?train))

;         (= (train_order_on_track ?train) 1)

;     )
;     :effect (and 
;         (increase (total-cost) 1) 
;         (when (not (is_direction_Aside ?train)) 
;             (increase (total-cost) 10) 
;         )
;         (is_direction_Aside ?train)

;         (not (train_at ?train ?trackFrom))
;         (train_at ?train ?trackTo)

;         (forall (?otherTrain - train) 
;             (when 
;                 (and (not (= ?otherTrain ?train)) (train_at ?otherTrain ?trackFrom))
;                 (decrease (train_order_on_track ?otherTrain) 1)
;             )
;         )
;         (increase (track_length ?trackFrom) (train_length ?train))
;         (decrease (track_length ?trackTo) (train_length ?train))
        
;         (assign (train_order_on_track ?train) (+ (num_trains_on_track ?trackTo) 1))

;         (decrease (num_trains_on_track ?trackFrom) 1)
;         (increase (num_trains_on_track ?trackTo) 1)

;         (block ?trackFrom)
;         (block_mutex_holder ?trackFrom ?train)

;         (block ?trackMiddle)
;         (block_mutex_holder ?trackMiddle ?train)

;         (not (servicable ?train))
;         (when (service_allowed ?trackTo) (servicable ?train))

;         (not (parkable ?train))
;         (when (not (parking_disallowed ?trackTo)) (parkable ?train))
;     )
; )

(:action move_Bside
    :parameters (
        ?train - train
        ?trackFrom - track
        ?trackTo - track
    )
    :precondition (and 
        (is_active ?train)
        (train_at ?train ?trackFrom)
        (not (is_parking ?train))

        (not (block ?trackTo))
        (not (block ?trackFrom))

        (tracks_linked ?trackTo ?trackFrom)

        (>= (track_length ?trackTo) (train_length ?train))

        (= (train_order_on_track ?train) (num_trains_on_track ?trackFrom))

    )
    :effect (and 
        (increase (total-cost) 1) 
        (when (is_direction_Aside ?train)
            (increase (total-cost) 10) 
        )
        (not (is_direction_Aside ?train))

        (not (train_at ?train ?trackFrom))
        (train_at ?train ?trackTo)

        (forall (?otherTrain - train) 
            (when 
                (and (not (= ?otherTrain ?train)) (train_at ?otherTrain ?trackTo))
                (increase (train_order_on_track ?otherTrain) 1)
            )
        )
        (increase (track_length ?trackFrom) (train_length ?train))
        (decrease (track_length ?trackTo) (train_length ?train))
        (decrease (num_trains_on_track ?trackFrom) 1)
        (increase (num_trains_on_track ?trackTo) 1)
        (assign (train_order_on_track ?train) 1)

        (block ?trackFrom)
        (block_mutex_holder ?trackFrom ?train)

        (not (servicable ?train))
        (when (service_allowed ?trackTo) (servicable ?train))

        (not (parkable ?train))
        (when (not (parking_disallowed ?trackTo)) (parkable ?train))
    )
)



)
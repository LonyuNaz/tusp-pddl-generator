from enum import Enum


class DomainConfig(Enum):
    Numeric = 1
    TemporalAndNumeric = 2

class DirectionStrategy(Enum):
    Aside = 1
    Bside = 2
    NO_DIRECTION = 3

class TrackOccupationStrategy(Enum):
    OCCUPIED_LENGTH = 1
    STACK_LOCATION = 2
    ORDER = 3
    
class GoalStates(Enum):
    IS_PARKING = 1
    WAS_SERVICED = 2
    PARKING_AFTER_SERVICE = 3
    LOCATION_AFTER_SERVICE = 4
    EXIT = 5
    LOCATION = 6

class Direction(Enum):
    ASIDE = 1
    BSIDE = 2
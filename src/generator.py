from typing import Tuple, List, Union
from .shared import GoalStates

import random


class TrainGenerator:
    def __init__(self, length: int, goal: GoalStates = GoalStates.PARKING_AFTER_SERVICE):
        self.length = length
        self.goal = goal

class TrackGenerator:
    def __init__(self, layer: int, length: int, parking: bool, service: bool):
        self.layer = layer
        self.length = length
        self.parking = parking
        self.service = service
    
    def __repr__(self) -> str:
        return self.__str__()
    
    def __str__(self) -> str:
        return f'layer={self.layer}, length={self.length}, parking={self.parking}, service={self.service}'

class YardGenerator:
    def __init__(self, 
                 num_trains: int = 5,
                 train_lengths: Tuple[int] = (80,),
                 num_tracks: int = 3,
                 track_lengths: Tuple[int] = (80,),
                 num_connections: int = 20,
                 steps_until_service: int = 1,
                 steps_until_parking: int = 2                 
                ):
        
        
        assert steps_until_parking > 0 or steps_until_service > 0
        assert steps_until_parking != steps_until_service

        self.parking_layer = steps_until_parking
        self.service_layer = steps_until_service

        if steps_until_parking > 0 and steps_until_service > 0:
            self.goal = GoalStates.PARKING_AFTER_SERVICE
            self.num_layers = max(steps_until_parking, steps_until_service)
        elif steps_until_parking > 0:
            self.goal = GoalStates.IS_PARKING
            self.num_layers = steps_until_parking
        else: #steps_until_service > 0 implied
            self.goal = GoalStates.WAS_SERVICED
            self.num_layers = steps_until_service

        self.init_trains(num_trains, train_lengths)
        self.init_tracks(num_tracks, track_lengths)
        self.init_connections()

        assert num_connections > (len(self.connections) + len(self.entry_conns))

        self.finalize_connections(num_connections)

        assert num_connections == (len(self.connections) + len(self.entry_conns))


    def init_trains(self, num_trains, train_lengths):
        self.trains = [TrainGenerator(random.choice(train_lengths)) for _ in range(num_trains)]

    def init_tracks(self, num_tracks, track_lengths):
        self.tracks = [TrackGenerator(l, random.choice(track_lengths), (l+1)==self.parking_layer, (l+1)==self.service_layer) for l in range(self.num_layers)]
        while len(self.tracks) < num_tracks:
            l = random.choice(range(self.num_layers))
            self.tracks.append(TrackGenerator(l,  random.choice(track_lengths), (l+1)==self.parking_layer, (l+1)==self.service_layer))

    def init_connections(self):
        self.connections = []
        self.entry_conns = [random.choice(self.get_layer_idx(0))]
        for l in range(self.num_layers-1):
            for t in self.get_layer_idx(l):
                conn = (t, random.choice(self.get_layer_idx(l+1)))
                if conn not in self.connections:
                    self.connections.append(conn)

    def finalize_connections(self, num_connections):
        max_failures = 1000
        fail_counter = 0
        while (len(self.connections) + len(self.entry_conns)) < num_connections and fail_counter < max_failures:
            if random.random() < (1/len(self.tracks)):
                #left_track = entry track
                right_track = random.choice(self.get_layer_idx(0))
                if right_track not in self.entry_conns:
                    self.entry_conns.append(right_track)
            else:
                left_track_candidates = [i for i in range(len(self.tracks)) if self.tracks[i].layer < (self.num_layers -1)]
                if len(left_track_candidates) == 0:
                    fail_counter += 1
                    break
                left_track = random.choice(left_track_candidates)
                right_track_candidates = [i for i in range(len(self.tracks)) if self.tracks[i].layer == (self.tracks[left_track].layer + 1)]
                if len(right_track_candidates) == 0:
                    fail_counter += 1
                    continue
                right_track = random.choice(right_track_candidates)
                conn = (left_track, right_track)
                if conn not in self.connections:
                    fail_counter = 0
                    self.connections.append(conn)
                else:
                    fail_counter += 1


    def get_layer_idx(self, l):
        return [i for i in range(len(self.tracks)) if self.tracks[i].layer == l]
    
    
    def get_track_connections(self):
        conns = []
        for c in self.connections:
            layer_0 = self.tracks[c[0]].layer
            layer_1 = self.tracks[c[1]].layer
            number_0 = self.get_layer_idxs(layer_0).index(c[0])+1
            number_1 = self.get_layer_idxs(layer_1).index(c[1])+1
            conns.append((f'{chr(97+layer_0)}_{number_0}', f'{chr(97+layer_1)}_{number_1}'))
        return conns

    def get_entry_connections(self):
        conns = []
        for c in self.entry_conns:
            number_0 = self.get_layer_idxs(0).index(c)+1
            conns.append(f'{chr(97)}_{number_0}')
        return conns
    
    def get_servicing_tracks(self):
        tracks = []
        l = self.goal1_steps - 1
        for i_i, i in enumerate(self.get_layer_idxs(l)):
            tracks.append(f'{chr(97+l)}_{i_i+1}')
        return tracks




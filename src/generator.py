from typing import Tuple, List, Union
from .shared import GoalStates

import random
import numpy as np


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
                 steps_until_parking: int = 2,
                 num_service_tracks: int = 1,    
                 num_parking_tracks: int = 1,            
                ):
        
        
        assert steps_until_parking > 0 or steps_until_service > 0
        assert steps_until_parking != steps_until_service

        self.parking_layer = steps_until_parking
        self.service_layer = steps_until_service

        if steps_until_parking > 0 and steps_until_service > 0:
            self.goal = GoalStates.PARKABLE_AFTER_SERVICE
            # self.goal = GoalStates.WAS_SERVICED
            self.num_layers = max(steps_until_parking, steps_until_service)
        elif steps_until_parking > 0:
            self.goal = GoalStates.PARKABLE
            self.num_layers = steps_until_parking
        else: #steps_until_service > 0 implied
            self.goal = GoalStates.WAS_SERVICED
            self.num_layers = steps_until_service

        self.init_trains(num_trains, train_lengths)

        for _ in range(int(1e6)):
            self.init_tracks(num_tracks, track_lengths, num_parking_tracks, num_service_tracks)
            while self.total_parking_length() < sum([t.length for t in self.trains]):
                self.add_parking_space(train_lengths)
            self.init_connections()
            if self.num_possible_connections() >= num_connections and\
                num_connections > (len(self.connections) + len(self.entry_conns)):
                break

        assert num_connections > (len(self.connections) + len(self.entry_conns))

        self.finalize_connections(num_connections)

        assert num_connections == (len(self.connections) + len(self.entry_conns))

    def num_possible_connections(self):
        counter = 0
        for l in range(self.num_layers-1):
            counter += len(self.get_layer_idx(l)) * len(self.get_layer_idx(l+1))
        return counter
    
    def count_parking_tracks(self):
        return len([t for t in self.tracks if t.parking])

    def total_parking_length(self):
        return sum(t.length for t in self.tracks if t.parking)
    
    def total_service_length(self):
        return sum(t.length for t in self.tracks if t.service)
    
    def add_parking_space(self, train_lengths):
        parking_tracks = [i for i in range(len(self.tracks)) if self.tracks[i].parking]
        selected_track = random.choice(parking_tracks)
        self.tracks[selected_track].length = int(self.tracks[selected_track].length + np.mean(train_lengths))

    def add_service_space(self, train_lengths):
        service_tracks = [i for i in range(len(self.tracks)) if self.tracks[i].service]
        selected_track = random.choice(service_tracks)
        self.tracks[selected_track].length = int(self.tracks[selected_track].length + np.mean(train_lengths))

    def init_trains(self, num_trains, train_lengths):
        self.trains = [TrainGenerator(random.choice(train_lengths), self.goal) for _ in range(num_trains)]

    def init_tracks(self, num_tracks, track_lengths, num_parking_tracks, num_service_tracks):
        self.tracks = []
        for l in range(self.num_layers):
            if (l+1) == self.service_layer:
                self.tracks += [TrackGenerator(l, random.choice(track_lengths), False, True) for _ in range(num_service_tracks)]
            else:
                self.tracks.append(TrackGenerator(l, random.choice(track_lengths), False, False))

        while len(self.tracks) < num_tracks:
            l = random.choice(range(self.num_layers))
            self.tracks.append(TrackGenerator(l, random.choice(track_lengths), False, False))

        non_service_tracks = [i for i in range(len(self.tracks)) if not self.tracks[i].service]
        chosen_parking_tracks = random.sample(non_service_tracks, num_parking_tracks)
        for i in chosen_parking_tracks:
            self.tracks[i].parking = True

    def init_connections(self):
        self.connections = []
        self.entry_conns = self.get_layer_idx(0)
        for l in range(self.num_layers-1):
            for t in self.get_layer_idx(l):
                conn = (t, random.choice(self.get_layer_idx(l+1)))
                if conn not in self.connections:
                    self.connections.append(conn)

    def finalize_connections(self, num_connections):
        max_failures = 1e6
        fail_counter = 0
        while (len(self.connections) + len(self.entry_conns)) < num_connections and fail_counter < max_failures:
            left_track_candidates = [i for i in range(len(self.tracks)) if self.tracks[i].layer < (self.num_layers -1)]
            if len(left_track_candidates) == 0:
                fail_counter += 1
                continue
            left_track = random.choice(left_track_candidates)
            right_track_candidates = [i for i in range(len(self.tracks)) if self.tracks[i].layer == (self.tracks[left_track].layer + 1) and (left_track, i) not in self.connections]
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
    
    def is_fully_connected(self, i):
        track = self.tracks[i]
        next_layer = track.layer + 1
        conns = [c for c in self.connections if c[0] == i]
        return len(conns) == len(self.get_layer_idx(next_layer))
    
    
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




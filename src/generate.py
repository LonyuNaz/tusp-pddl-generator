import typing
import os
import json
import re
from typing import List, Dict, Tuple
from pathlib import Path
import networkx as nx 
import matplotlib.pyplot as plt 
from enum import Enum
from random import random

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
    
class GoalStates(Enum):
    IS_PARKING = 1
    SERVICED_PARKING = 2


class Train:

    def __init__(self, name, length, speed=0, active=True):
        self.name = "train_" + name
        self.length = length
        self.speed = speed
        self.active = active

    def __str__(self) -> str:
        return f"name: {self.name} --- length: {self.length} --- speed: {self.speed} --- active: {self.active}" 
    
    def __repr__(self) -> str:
        return self.name


class Track:

    def __init__(self, name, length, parking=True, servicing=False):
        self.name = "track_" + name
        self.length = length
        self.parking = parking
        self.servicing = servicing

    def __str__(self) -> str:
        return f"name: {self.name} --- length: {self.length} --- parking: {self.parking}" 
    
    def __repr__(self) -> str:
        return self.name


class ShuntingYard:

    def __init__(self, 
                 instance_name: str, 
                 domain_name: str, 
                 config: DomainConfig, 
                 direction_strategy: DirectionStrategy = DirectionStrategy.Aside,
                 negative_preconditions = False,
                 track_occupation_strategy: TrackOccupationStrategy = TrackOccupationStrategy.STACK_LOCATION,
                 goal_states: GoalStates = GoalStates.IS_PARKING,
                 max_concurrent_movements: int = 0
                ):
        self.domain_name = domain_name
        self.instance_name = instance_name
        
        self.drivers = []
        self.trains = []
        self.tracks = []
        self.track_connections = []
        self.entry_track_connections = []
        self.exit_order = []

        self.is_entry_connection_a_side = True
        self.is_temporal = config == DomainConfig.TemporalAndNumeric
        self.is_numeric = True

        self.direction_strategy = direction_strategy
        self.negative_preconditions = negative_preconditions

        self.track_occupation_strategy = track_occupation_strategy
        self.goal_states = goal_states
        self.max_concurrent_movements = max_concurrent_movements

    def from_json(self, filename: str, include_switches=False):

        with open(filename, 'r') as f:
            json_txt = f.read()
        obj = json.loads(json_txt)

        tracks = obj['trackParts']
        for track in tracks:
            track['name'] = re.sub('[^0-9a-zA-Z]+', '_', track['name'])

        tracks_parsed = [(rr['name'], int(rr['length']), rr['type'] == 'RailRoad' and rr['parkingAllowed']) 
                         for rr in tracks if rr['type'] != 'Bumper' and (include_switches or rr['type'] == 'RailRoad')] 

        if not include_switches:
            def find_aside_connection(track, tracks, connections):
                aside_connections = track['aSide']
                for aside_conn_id in aside_connections:
                    aside_conn = next(t for t in tracks if t['id'] == aside_conn_id)
                    if aside_conn['type'] == 'RailRoad':
                        connections.add(aside_conn['name'])
                    else:
                        connections.union(find_aside_connection(aside_conn, tracks, connections))
                return connections 
        else:
            def find_aside_connection(track, tracks, connections):
                aside_connections = track['aSide']
                for aside_conn_id in aside_connections:
                    aside_conn = next(t for t in tracks if t['id'] == aside_conn_id)
                    if aside_conn['type'] != 'Bumper':
                        connections.add(aside_conn['name'])
                    else:
                        connections.union(find_aside_connection(aside_conn, tracks, connections))
                return connections
            
        links = []
        for track in tracks:
            if track['type'] == 'Bumper' or (not include_switches and track['type'] != 'RailRoad'):
                continue
            aside_tracks = find_aside_connection(track, tracks, set())
            for other in aside_tracks:
                links.append((track['name'], other))

        self.set_tracks(tracks_parsed)
        self.set_track_connections(links)

    def set_exit_order(self, names: List[str]):
        self.exit_order = []
        for name in names:
            for train in self.trains:
                if train.name.endswith(name):
                    self.exit_order.append(train)
                    break
        

    def set_servicing_tracks(self, names: List[str]):
        for track in self.tracks:
            if any(track.name.endswith(name) for name in names):
                track.servicing = True
                track.parking = False

    def set_drivers(self, names: List[str]):
        self.drivers = names

    def set_trains(self, trains: List[Tuple[str, int, int, bool]]):
        self.trains = [Train(name, length, speed, active) for name, length, speed, active in trains]

    def set_tracks(self, tracks: List[Tuple[str, int, bool]]):
        self.tracks = [Track(name, length, parking) for name, length, parking in tracks]

    def set_track_connections(self, track_connections: List[Tuple[str, str]]):
        self.track_connections = []
        for bside, aside in track_connections:
            track_bside =  next(track for track in self.tracks if track.name == "track_" + bside)
            track_aside =  next(track for track in self.tracks if track.name == "track_" + aside)

            self.track_connections.append((track_bside,track_aside))

    def set_entry_track_connections(self, entry_track_connections: List[str], a_side: bool = True):
        self.entry_track_connections = entry_track_connections
    def remove_track(self, name: str):
        self.tracks = [t for t in self.tracks if t.name != f"track_{name}"]
        self.track_connections = [c for c in self.track_connections if f"track_{name}" not in str(c)]
        self.entry_track_connections = [c for c in self.entry_track_connections if f"track_{name}" not in str(c)]

    def order_nodes(self, lefts):
        new_lefts = []
        new_rights = []
        for left in lefts:
            if left not in new_lefts:
                new_lefts.append(left)
                rights = [c[1].name for c in self.track_connections if c[0].name == left]
                for right in rights:
                    if right not in new_rights:
                        new_rights.append(right)
                    similar_lefts = [c[0].name for c in self.track_connections if c[0].name in lefts and c[1].name == right]
                    for l in similar_lefts:
                        if l not in new_lefts:
                            new_lefts.append(l)
            else:
                continue
        return new_lefts, new_rights
            
             

    def visualize(self, track_name=None, figsize=(12,12)): 
        G = nx.Graph() 

        if track_name is None:
            cons = self.track_connections.copy()
            lefts = [conn[0].name for conn in self.track_connections] 
            rights = [conn[1].name for conn in self.track_connections]
            current_lefts = [t for t in lefts if t not in rights]
            start_x = 0
            nodes_added = []
            graph_height = len(self.tracks) / 2
            while len(cons) > 0:
                print(len(cons))
                current_lefts, next_lefts = self.order_nodes(current_lefts)
                current_lefts = [l for l in current_lefts if l not in nodes_added]
                if len(current_lefts) == 0:
                    break
                for idx, l in enumerate(current_lefts):
                    w = start_x + ((random() * 2) - 1) * 0.1
                    h = (graph_height - len(current_lefts)) / 2 + idx
                    G.add_node(l,pos=(w,h),label=l)
                    nodes_added.append(l)
                start_x += 1
                cons = [c for c in cons if c[0].name not in current_lefts]
                lefts = [conn[0].name for conn in cons ] 
                rights = [conn[1].name for conn in cons ] 
                current_lefts = next_lefts
            lefts = [conn[0].name for conn in self.track_connections if conn[0].name not in nodes_added]
            rights = [conn[1].name for conn in self.track_connections if conn[1].name not in nodes_added]
            for idx, l in enumerate(lefts):
                w = start_x + ((random() * 2) - 1) * 0.1
                h = (graph_height - len(lefts)) / 2 + idx
                G.add_node(l,pos=(w,h),label=l)
            for idx, r in enumerate(rights):
                w = start_x + ((random() * 2) - 1) * 0.1
                h = (graph_height - len(rights)) / 2 + idx
                G.add_node(r,pos=(w,h),label=r)
            for l, r in self.track_connections:
                G.add_edge(l.name, r.name)
            
        else:
            lefts = [conn[0].name for conn in self.track_connections if conn[1].name == f"track_{track_name}"] 
            rights = [conn[1].name for conn in self.track_connections if conn[0].name == f"track_{track_name}"] 
            for idx, l in enumerate(lefts):
                G.add_node(l,pos=(0,idx),label=l)
            for idx, r in enumerate(rights):
                G.add_node(r,pos=(2,idx),label=r)
            h = max(len(lefts), len(rights)) / 2
            G.add_node(track_name,pos=(1,h))
            for idx, l in enumerate(lefts):
                G.add_edge(l,track_name)
            for idx, r in enumerate(rights):
                G.add_edge(track_name, r)

        plt.figure(figsize=figsize) 
        pos=nx.get_node_attributes(G,'pos')
        nx.draw_networkx_labels(G, pos, labels = {key:key for key in pos.keys()}, font_size = 12)
        nx.draw(G, pos) 

    def generate_instance(self):
        
        self._generate_entry_track()

        instance_text = ["(define ", f"(problem {self.instance_name})", f"(:domain {self.domain_name})"]
        instance_text += self._generate_objects()
        instance_text += self._generate_init()
        instance_text += self._generate_goal()
        if self.is_numeric and not self.is_temporal:
            instance_text += ["", "(:metric minimize (cost))", ")"]
        filename = Path(self.instance_name + "_" + str(len(self.trains)) + "t.pddl")
        filename.touch(exist_ok=True) 

        if os.path.exists(filename):
            os.remove(filename)

        with open(filename, 'w+') as f:
            f.write("\n".join(instance_text))
        

    def _generate_objects(self):
        if self.is_numeric:
            return self._generate_objects_numeric()
        else:
            return self._generate_objects_classical()


    def _generate_objects_numeric(self):
        
        instance_text = ["(:objects"]
        if len(self.drivers) > 0:
            instance_text += ["\t; drivers", "\t; ================================ "]
            instance_text += [f"\t{name} - driver" for name in self.drivers]
            instance_text += [""]
        instance_text += ["\t; tracks", "\t; ================================ "]
        instance_text += [f"\t{track.name} - track" for track in self.tracks]
        instance_text += [""]
        instance_text += ["\t; trains", "\t; ================================ "]
        instance_text += [f"\t{train.name} - train" for train in self.trains]
        instance_text += [")"]
        return instance_text
    
    
    def _generate_objects_classical(self):
        return
    

    def _generate_entry_track(self):
        if self.is_numeric:
            self._generate_entry_track_numeric()
        else:
            self._generate_entry_track_classical()
    

    def _generate_init(self):
        instance_text = ["", "(:init", ""]
        if self.is_numeric:
            return instance_text + self._generate_init_numeric() + ["", ")"]
        else:
            return instance_text + self._generate_init_classical() + ["", ")"]


    def _generate_init_numeric(self):
        instance_text = []
        if not self.is_temporal:
            instance_text += ["\t; metric", "\t; ================================ "]
            instance_text += [f"\t(= (cost) 0)"]
            instance_text += [""]
        if len(self.drivers) > 0:
            instance_text += ["\t; drivers", "\t; ================================ "]
            instance_text += [f"\t(idle {driver})" for driver in self.drivers]
            instance_text += [""]

        if self.max_concurrent_movements > 0 and self.is_temporal:
            instance_text += ["\t; concurrent movement", "\t; ================================ "]
            instance_text += [f"\t(= (max_num_consecutive_movements) {self.max_concurrent_movements})"]
            instance_text += [f"\t(= (num_consecutive_movements) 0)", ""]

        max_train_length = max([t.length for t in self.trains])

        instance_text += ["\t; track parking", "\t; ================================ "]
        if not self.negative_preconditions:
            instance_text += [f"\t(parking_allowed {track.name})" for track in self.tracks if track.parking != self.negative_preconditions and track.length >= max_train_length]
        else:
            instance_text += [f"\t(parking_disallowed {track.name})" for track in self.tracks[:-1] if track.parking != self.negative_preconditions or track.length < max_train_length]
            instance_text += [f"\t(parking_disallowed {self.tracks[-1].name})"]
        instance_text += [""]

        instance_text += ["\t; track servicing", "\t; ================================ "]
        instance_text += [f"\t(service_allowed {track.name})" for track in self.tracks if track.servicing]
        instance_text += [""]

        instance_text += ["\t; track lengths", "\t; ================================ "]
        instance_text += [f"\t(= (track_length {track.name}) {max(track.length, max_train_length)})" for track in self.tracks]
        instance_text += [""]

        instance_text += ["\t; track trains", "\t; ================================ "]
        for idx, track in enumerate(self.tracks):
            if idx == (len(self.tracks) - 1):
                num_trains = len(self.trains)
            else:
                num_trains = 0
            instance_text += [f"\t(= (num_trains_on_track {track.name}) {num_trains})"]
        instance_text += [""]

        instance_text += ["\t; track spaces", "\t; ================================ "]
        for idx, track in enumerate(self.tracks):
            if idx == (len(self.tracks) - 1):
                aside_len = track.length
            else:
                aside_len = 0

            if self.track_occupation_strategy == TrackOccupationStrategy.OCCUPIED_LENGTH:
                instance_text += [f"\t(= (track_Aside_occupied_length {track.name}) {aside_len})"]
                instance_text += [f"\t(= (track_Bside_occupied_length {track.name}) 0)"]
            elif self.track_occupation_strategy == TrackOccupationStrategy.STACK_LOCATION:
                instance_text += [f"\t(= (stack_Aside_distance_to_end_of_track {track.name}) 0)"]
                instance_text += [f"\t(= (stack_Bside_distance_to_end_of_track {track.name}) {aside_len})"]
        
        instance_text += [""]
        instance_text += ["\t; inter track connections", "\t; ================================ "]
        instance_text += [f"\t(tracks_linked {track_bside.name} {track_aside.name})" for track_bside, track_aside in self.track_connections]
        instance_text += [""]

        instance_text += ["\t; train activity", "\t; ================================ "]
        instance_text += [f"\t(is_active {train.name})" for train in self.trains]
        instance_text += [""]

        if self.is_temporal:
            instance_text += ["\t; train availability", "\t; ================================ "]
            instance_text += [f"\t(is_available {train.name})" for train in self.trains]
            instance_text += [""]

        if self.direction_strategy == DirectionStrategy.Aside:
            instance_text += ["\t; train direction (default Aside)", "\t; ================================ "]
            instance_text += [f"\t(is_direction_Aside {train.name})" for train in self.trains]
            instance_text += [""]
        elif self.direction_strategy == DirectionStrategy.Bside:
            instance_text += ["\t; train direction (default Bside)", "\t; ================================ "]
            instance_text += [f"\t(is_direction_Bside {train.name})" for train in self.trains]
            instance_text += [""]

        if not self.negative_preconditions and self.max_concurrent_movements == 0:
            instance_text += ["\t; trains unoperated", "\t; ================================ "]
            instance_text += [f"\t(train_unoperated {train.name})" for train in self.trains]
            instance_text += [""]

        instance_text += ["\t; train lengths", "\t; ================================ "]
        instance_text += [f"\t(= (train_length {train.name}) {train.length})" for train in self.trains]
        instance_text += [""]

        instance_text += ["\t; train locations", "\t; ================================ "]
        instance_text += [f"\t(train_at {train.name} {self.tracks[-1].name})" for train in self.trains]
        instance_text += [""]

        current_distance = 0
        for train in self.trains:
            instance_text += [f"\t(= (train_distance_to_end_of_track {train.name}) {current_distance})"]
            current_distance += train.length

        return instance_text
        
    def _generate_init_classical(self):
        return 

    def _generate_entry_track_numeric(self):
        tot_len = sum(train.length for train in self.trains)

        entry_track = Track("entry", tot_len)
        entry_track.parking = False

        if self.tracks[-1].name != "entry":
            self.tracks.append(entry_track)
        else:
            self.tracks[-1] = entry_track

        for conn in self.entry_track_connections:
            other_track = next(track for track in self.tracks if track.name == "track_" + conn)
            if self.is_entry_connection_a_side:
                self.track_connections.append((entry_track, other_track))
            else:
                self.track_connections.append((other_track, entry_track))


    def _generate_entry_track_classical(self):
        return
    

    def _generate_goal(self):
        instance_text = ["", "(:goal (and ", ""]
        if self.is_numeric:
            return instance_text + self._generate_goal_numeric() + ["", "))"]
        else:
            return instance_text + self._generate_goal_classic() + ["", "))"]
        

    def _generate_goal_numeric(self):
        instance_text = []
        if len(self.exit_order) > 0:
            instance_text += ["\t; train exit", "\t; ================================ "]
            instance_text += [f"\t(train_at {train.name} {self.tracks[-1].name})" for train in self.trains]
            instance_text += ["\t; train exit order", "\t; ================================ "]
            instance_text += [f"\t(> (train_distance_to_end_of_track {self.exit_order[i].name}) (train_distance_to_end_of_track {self.exit_order[i+1].name}))" for i in range(len(self.exit_order)-1)]
            instance_text += ["\t; train parking", "\t; ================================ "]
            instance_text += [f"\t(has_parked {train.name})" for train in self.trains]
        elif self.goal_states == GoalStates.IS_PARKING or self.goal_states == GoalStates.SERVICED_PARKING:
            instance_text += ["\t; train parking", "\t; ================================ "]
            instance_text += [f"\t(is_parking {train.name})" for train in self.trains]
        if self.goal_states == GoalStates.SERVICED_PARKING:
            instance_text += ["\t; train service", "\t; ================================ "]
            instance_text += [f"\t(was_serviced {train.name})" for train in self.trains]

        
        
        return instance_text
    

    def _generate_goal_classic(self):
        return

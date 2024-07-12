from typing import Tuple, List
import random

class Track:
    def __init__(self, layer: int, length: int, parking: bool, service: bool):
        self.layer = layer
        self.length = length
        self.parking = parking
        self.service = service
    
    def __repr__(self) -> str:
        return self.__str__()
    
    def __str__(self) -> str:
        return f'layer={self.layer}, length={self.length}, parking={self.parking}, service={self.service}'

class YardCreator:
    def __init__(self, 
                 num_trains: int = 5,
                 train_length: int = 80,
                 num_tracks: int = 3,
                 train_track_length_ratio: float = 0.05,
                 conn_mult: int = 3,                                  
                 goal1_steps: int = 3,
                 goal2_steps: int = 1,                
                ):
        self.num_trains = num_trains
        self.train_length = train_length
        self.total_train_length = num_trains * train_length
        self.num_tracks = num_tracks
        assert train_track_length_ratio > 0
        self.train_track_length_ratio = train_track_length_ratio
        self.goal1_steps = goal1_steps
        self.goal2_steps = goal2_steps
        self.conn_mult = conn_mult
        self.tracks: List[Track] = []
        self.connections: List[Tuple[int, int]] = []
        self.entry_conns: List[int] = []
        self.num_layers = max(self.goal1_steps, self.goal2_steps)


    def ttlr(self):
        return self.total_train_length / sum(t.length for t in self.tracks)

    def get_layer_idxs(self, l):
        return [i for i in range(len(self.tracks)) if self.tracks[i].layer == l]
    
    def extendable_track_idxs(self):
        return [i for i in range(len(self.tracks)) if self.tracks[i].layer != (self.goal1_steps-1)]
    
    def chosable_layer_idxs(self):
        return [i for i in range(self.num_layers) if i != (self.goal1_steps-1)]

    def extend_tracks(self):
        parking_layer = self.goal2_steps-1
        while sum(self.tracks[t].length for t in self.get_layer_idxs(parking_layer)) < self.num_trains * self.train_length:
            chosen_track_idx = random.choice(self.get_layer_idxs(parking_layer))
            self.tracks[chosen_track_idx].length += self.train_length
        while self.ttlr() > self.train_track_length_ratio:
            chosen_track_idx = random.choice(self.extendable_track_idxs())
            self.tracks[chosen_track_idx].length += self.train_length

    def init_tracks(self):
        self.tracks = [Track(i, self.train_length, (i+1)==self.goal2_steps, (i+1)==self.goal1_steps) for i in range(self.num_layers)]
        while len(self.tracks) < self.num_tracks:
            l = random.choice(self.chosable_layer_idxs())
            self.tracks.append(Track(l, self.train_length, (l+1)==self.goal2_steps, (l+1)==self.goal1_steps))

    def connectable_track_idxs(self, t_idx: int):
        current_layer = self.tracks[t_idx].layer
        connectable_tracks = self.get_layer_idxs(current_layer+1)
        current_connetions = [c for c in self.connections if c[0] == t_idx]
        return [c for c in connectable_tracks if c not in current_connetions]

    def init_connections(self):
        self.connections = []
        self.entry_conns = [random.choice(self.get_layer_idxs(0))]
        for l in range(self.num_layers-1):
            for t in self.get_layer_idxs(l):
                conn = (t, random.choice(self.get_layer_idxs(l+1)))
                if conn not in self.connections:
                    self.connections.append(conn)
    
    def add_connections(self):
        num_failures = 0
        while len(self.connections) < (self.conn_mult * len(self.tracks)) and num_failures < 1000:
            t_idx = random.choice(range(len(self.tracks)+1))
            if t_idx == len(self.tracks):
                possible_conns = self.get_layer_idxs(0)
                conn = random.choice(possible_conns)
                self.entry_conns.append(conn)
            else:
                possible_conns = self.connectable_track_idxs(t_idx)
                if len(possible_conns) > 0:
                    conn = random.choice(possible_conns)
                    self.connections.append((t_idx, conn))
                else:
                    num_failures += 1

    def create_layout(self):
        self.init_tracks()
        self.extend_tracks()
        self.init_connections()
        self.add_connections()

    def get_track_init(self):
        tracks = []
        for l in range(self.num_layers):
            for i_i, i in enumerate(self.get_layer_idxs(l)):
                tracks.append((f'{chr(97+l)}_{i_i+1}', self.tracks[i].length, self.tracks[i].parking))
        return tracks

    def get_train_init(self):
        return [(str(i), self.train_length, True) for i in range(self.num_trains)]
    
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




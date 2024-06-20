import argparse
from generate import *

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('instance_name', 
                        help="Name of to be created PDDL problem instance")
    parser.add_argument('domain_name', 
                        help="Name of PDDL domain used in problem instance")
    parser.add_argument('--config', choices=[1, 2], 
                        help="Configuration to be used:\n1 = numeric\n2 = numeric & temporal", default=1)
    parser.add_argument('--goal', choices=[1, 2], 
                        help="Goal states of themodel:\n1 = is_parking for all trains\n2 = was_serviced and is_parking for all trains", default=1)
    parser.add_argument('--direction', choices=[1, 2, 3], 
                        help="Default direction of trains:\n1 = A side\n2 = B side\n3 = No direction", default=3)
    parser.add_argument('--negative-preconditions', 
                        help="Negative preconditions included in domain file", action=argparse.BooleanOptionalAction, default=False)
    parser.add_argument('--track-occupation', choices=[1, 2], 
                        help="Model the length of a track that is occupied:\n1 = Occupied length\n2 = Stacks on A/B side", default=1)
    parser.add_argument('--concurrent-movements', type=int, 
                        help="Model the length of a track that is occupied:\nl = Occupied length\ns = Stacks on A/B side", default=0)
    
    args = parser.parse_args()

    yard = ShuntingYard(
        args.instance_name, 
        args.domain_name,
        args.config,
        args.direction,
        args.negative_preconditions,
        args.track_occupation,
        args.goal,
        args.concurrent_movements
    )

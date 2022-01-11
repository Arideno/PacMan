import numpy as np
from train_dqn import build_agent
from pacman_env import PacmanEnv


if __name__ == '__main__':
    env = PacmanEnv()
    HEIGHT, WIDTH, CHANNELS = env.observation_space.shape
    ACTIONS = env.action_space.n

    dqn = build_agent(HEIGHT, WIDTH, CHANNELS, ACTIONS)

    dqn.load_weights('dqn_weights.h5')

    scores = dqn.test(env, nb_episodes=10, visualize=True, action_repetition=10)
    print(np.mean(scores.history['episode_reward']))
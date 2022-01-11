from gym.spaces import space
import numpy as np
import gym
import pygame
from PIL import Image
from gym import spaces
from main import Game, SCREEN_WIDTH, SCREEN_HEIGHT

N_ACTIONS = 4

class PacmanEnv(gym.Env):
    def __init__(self):
        pygame.init()
        super().__init__()

        self.game = Game()
        self.action_space = spaces.Discrete(N_ACTIONS)
        self.observation_space = spaces.Box(
            low=0, high=255,
            shape=(SCREEN_WIDTH, SCREEN_HEIGHT, 3),
            dtype=np.uint8
        )
        self.prev_img = None

    def reset(self):
        self.game.__init__()
        return self.game.current_display_img

    def step(self, action):
        reward, done = self.game.run(action=action)
        return self.game.current_display_img, reward, done, {}

    def render(self, **kwargs):
        pygame.display.flip()
        pygame.event.pump()
        self.game.clock.tick(30)

    def close(self):
        pygame.quit()
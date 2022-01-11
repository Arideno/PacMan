import pygame
from pygame import key

MOVE_LEFT_ACTION = 0
MOVE_RIGHT_ACTION = 1
MOVE_UP_ACTION = 2
MOVE_DOWN_ACTION = 3
PLAYER_SPEED = 2

class Player(pygame.sprite.Sprite):
    def __init__(self, size, x, y):
        super().__init__()

        image = pygame.image.load('./assets/pacman.png')
        self.image = pygame.transform.scale(image, (size, size))
        self.rect = self.image.get_rect(center=(x, y))
        self.speed = PLAYER_SPEED

    def perform_action(self, action):
        if action == MOVE_LEFT_ACTION:
            self.rect.x -= self.speed
        elif action == MOVE_RIGHT_ACTION:
            self.rect.x += self.speed
        elif action == MOVE_UP_ACTION:
            self.rect.y -= self.speed
        elif action == MOVE_DOWN_ACTION:
            self.rect.y += self.speed

    def get_input(self):
        keys = pygame.key.get_pressed()

        if keys[pygame.K_a]:
            self.rect.x -= self.speed
        elif keys[pygame.K_d]:
            self.rect.x += self.speed
        elif keys[pygame.K_w]:
            self.rect.y -= self.speed
        elif keys[pygame.K_s]:
            self.rect.y += self.speed

    def constraint(self, obstacles):
        for obstacle in obstacles:
            if self.rect.colliderect(obstacle.rect):
                if self.rect.y > obstacle.rect.y:
                    self.rect.y += self.speed
                if self.rect.y < obstacle.rect.y:
                    self.rect.y -= self.speed
                if self.rect.x < obstacle.rect.x:
                    self.rect.x -= self.speed
                if self.rect.x > obstacle.rect.x:
                    self.rect.x += self.speed

    def update(self, obstacles):
        self.get_input()
        self.constraint(obstacles)
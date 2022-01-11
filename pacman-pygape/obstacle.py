import pygame

class Block(pygame.sprite.Sprite):
    def __init__(self, size, x, y):
        super().__init__()

        self.image = pygame.Surface((size, size))
        self.image.fill((0, 0, 255))

        self.rect = self.image.get_rect(center=(x, y))
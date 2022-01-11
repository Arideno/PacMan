import pygame

class Cherry(pygame.sprite.Sprite):
    def __init__(self, size, x, y):
        super().__init__()

        image = pygame.image.load('./assets/cherry.png')
        self.image = pygame.transform.scale(image, (size, size))
        self.rect = self.image.get_rect(center=(x, y))
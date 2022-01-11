import pygame

GHOST_SPEED = 2

class Ghost(pygame.sprite.Sprite):
    def __init__(self, size, x, y):
        super().__init__()

        image = pygame.image.load('./assets/ghost.png')
        self.image = pygame.transform.scale(image, (size, size))
        self.rect = self.image.get_rect(center=(x, y))
        self.speed = GHOST_SPEED
        self.target = None

    def move(self, path, size):
        if self.target is not None:
            if self.rect.x == self.target[0] * size and self.rect.y == self.target[1] * size:
                self.target = path[0]
        else:
            self.target = path[0]
        if self.target[0] * size == self.rect.x:
            if self.target[1] * size > self.rect.y:
                self.rect.y += GHOST_SPEED
            elif self.target[1] * size < self.rect.y:
                self.rect.y -= GHOST_SPEED
        elif self.target[1] * size == self.rect.y:
            if self.target[0] * size > self.rect.x:
                self.rect.x += GHOST_SPEED
            elif self.target[0] * size < self.rect.x:
                self.rect.x -= GHOST_SPEED
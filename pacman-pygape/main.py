import pygame
import sys
from pygame.surfarray import array3d
from obstacle import *
from player import Player
from ghost import Ghost
from cherry import Cherry
from random import randint

SCREEN_WIDTH = 200
SCREEN_HEIGHT = 200

TILE_SIZE = SCREEN_WIDTH / 10

OBSTACLE_CATEGORY = 1 << 0
PACMAN_CATEGORY = 1 << 1
GHOST_CATEGORY = 1 << 2
CHERRY_CATEGORY = 1 << 3

MAP_SHAPE = [
    'xxxxxxxxxx',
    'xxccccccxx',
    'xcccxxcccx',
    'xcxccccxcx',
    'xcxcxxcxcx',
    'xcxccccxcx',
    'xcccxxcccx',
    'xcxxxxxxcx',
    'xccccpcccx',
    'xxxxxxxxxx',
]

MAP = [[0 for _ in range(10)] for _ in range(10)]

def bfs(ghost_pos, player_pos, map):
    path = dict()

    visited = set()

    queue = []
    queue.append(ghost_pos)

    while len(queue) > 0:
        top = queue.pop()
        visited.add(top)
        if top == player_pos:
            break
        neighbors = get_neighbors(top, map)
        for neighbor in neighbors:
            if neighbor not in visited:
                path[neighbor] = top
                queue.insert(0, neighbor)

    points = []
        
    current = player_pos
    while current in path:
        points.append(current)
        current = path[current]

    return points[::-1]

def get_neighbors(pos, map):
    neighbors = []
    if pos[0] - 1 >= 0 and map[pos[1]][pos[0] - 1] & OBSTACLE_CATEGORY == 0:
        neighbors.append((pos[0] - 1, pos[1]))

    if pos[1] - 1 >= 0 and map[pos[1] - 1][pos[0]] & OBSTACLE_CATEGORY == 0:
        neighbors.append((pos[0], pos[1] - 1))

    if pos[0] + 1 < len(map[0]) and map[pos[1]][pos[0] + 1] & OBSTACLE_CATEGORY == 0:
        neighbors.append((pos[0] + 1, pos[1]))

    if pos[1] + 1 < len(map) and map[pos[1] + 1][pos[0]] & OBSTACLE_CATEGORY == 0:
        neighbors.append((pos[0], pos[1] + 1))

    return neighbors

class Game:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        self.clock = pygame.time.Clock()

        self.running = True
        self.game_result = None
        self.score = 0

        self.blocks = pygame.sprite.Group()
        self.cherries = pygame.sprite.Group()
        # self.font = pygame.font.Font('./assets/Pixeled.ttf', 3)

        self.create_map()

    def create_map(self):
        for row_index, row in enumerate(MAP_SHAPE):
            for col_index, col in enumerate(row):
                if col == 'x':
                    MAP[row_index][col_index] = OBSTACLE_CATEGORY
                elif col == 'c':
                    MAP[row_index][col_index] = CHERRY_CATEGORY
                elif col == 'p':
                    MAP[row_index][col_index] = PACMAN_CATEGORY

        random_x = randint(0, len(MAP_SHAPE[0])-1)
        random_y = randint(0, len(MAP_SHAPE)-1)

        while MAP[random_y][random_x] & CHERRY_CATEGORY == 0:
            random_x = randint(0, len(MAP_SHAPE[0])-1)
            random_y = randint(0, len(MAP_SHAPE)-1)

        MAP[random_y][random_x] = GHOST_CATEGORY | CHERRY_CATEGORY

        for row_index, row in enumerate(MAP):
            for col_index, col in enumerate(row):
                if col & OBSTACLE_CATEGORY != 0:
                    x = col_index * TILE_SIZE + TILE_SIZE / 2
                    y = row_index * TILE_SIZE + TILE_SIZE / 2
                    block = Block(TILE_SIZE, x, y)
                    self.blocks.add(block)
                if col & CHERRY_CATEGORY != 0:
                    x = col_index * TILE_SIZE + TILE_SIZE / 2
                    y = row_index * TILE_SIZE + TILE_SIZE / 2
                    cherry = Cherry(TILE_SIZE / 2, x, y)
                    self.cherries.add(cherry)
                if col & PACMAN_CATEGORY != 0:
                    x = col_index * TILE_SIZE + TILE_SIZE / 2
                    y = row_index * TILE_SIZE + TILE_SIZE / 2
                    self.player = pygame.sprite.GroupSingle(Player(TILE_SIZE, x, y))
                if col & GHOST_CATEGORY != 0:
                    x = col_index * TILE_SIZE + TILE_SIZE / 2
                    y = row_index * TILE_SIZE + TILE_SIZE / 2
                    self.ghost = pygame.sprite.GroupSingle(Ghost(TILE_SIZE, x, y))

    def collision_checks(self):
        total_reward = 0

        for cherry in self.cherries.sprites():
            if self.player.sprite.rect.colliderect(cherry.rect):
                total_reward += 10
                self.score += 10

                x = int(int(cherry.rect.x) // TILE_SIZE)
                y = int(int(cherry.rect.y) // TILE_SIZE)

                MAP[y][x] = MAP[y][x] & (~CHERRY_CATEGORY)

                cherry.kill()

        if len(self.cherries.sprites()) == 0:
            self.running = False
            self.game_result = 'w'

        if self.player.sprite.rect.colliderect(self.ghost.sprite.rect):
            self.running = False
            self.game_result = 'l'
            return total_reward

        return total_reward

    def run(self, action=None):
        self.player.sprite.perform_action(action)
        self.player.update(self.blocks.sprites())

        player_x = int(int(self.player.sprite.rect.x) // TILE_SIZE)
        player_y = int(int(self.player.sprite.rect.y) // TILE_SIZE)

        ghost_x = int(int(self.ghost.sprite.rect.x) // TILE_SIZE)
        ghost_y = int(int(self.ghost.sprite.rect.y) // TILE_SIZE)

        map_player_x = 0
        map_player_y = 0
        map_ghost_x = 0
        map_ghost_y = 0

        for y_index in range(len(MAP)):
            for x_index in range(len(MAP[y_index])): 
                if MAP[y_index][x_index] & PACMAN_CATEGORY != 0:
                    map_player_x = x_index
                    map_player_y = y_index

                if MAP[y_index][x_index] & GHOST_CATEGORY != 0:
                    map_ghost_x = x_index
                    map_ghost_y = y_index

        path = bfs((map_ghost_x, map_ghost_y), (map_player_x, map_player_y), MAP)
        if len(path) > 0:
            self.ghost.sprite.move(path, TILE_SIZE)
        ghost_x = int(int(self.ghost.sprite.rect.x) // TILE_SIZE)
        ghost_y = int(int(self.ghost.sprite.rect.y) // TILE_SIZE)

        for y_index in range(len(MAP)):
            for x_index in range(len(MAP[y_index])): 
                MAP[y_index][x_index] = MAP[y_index][x_index] & ~(PACMAN_CATEGORY | GHOST_CATEGORY)
        
        MAP[player_y][player_x] = MAP[player_y][player_x] | PACMAN_CATEGORY
        MAP[ghost_y][ghost_x] = MAP[ghost_y][ghost_x] | GHOST_CATEGORY

        self.screen.fill((30, 30, 30))
        self.player.draw(self.screen)
        self.blocks.draw(self.screen)
        self.cherries.draw(self.screen)
        self.ghost.draw(self.screen)

        reward = self.collision_checks()

        # self.display_score()
        if self.game_result == 'w':
            self.victory_message()

        return reward, self.game_over()

    def display_score(self):
        score_surf = self.font.render(f'score: {self.score}', False, 'white')
        score_rect = score_surf.get_rect(topleft=(10, 5))
        self.screen.blit(score_surf, score_rect)

    def victory_message(self):
        victory_surf = self.font.render('You won', False, 'white')
        victory_rect = victory_surf.get_rect(center=(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
        self.screen.blit(victory_surf, victory_rect)

    def game_over(self):
        return self.game_result is not None

    @property
    def current_display_img(self):
        return array3d(pygame.display.get_surface())[:, :, :]

if __name__ == '__main__':
    pygame.init()

    game = Game()
    while game.running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
        
        game.run()

        pygame.display.flip()
        game.clock.tick(60)

    pygame.quit()
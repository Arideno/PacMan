(defclass Square []
    (defn __init__ [self x y]
        (setv self.x x)
        (setv self.y y)
    )

    (defn get_adjacent_squares [self]
        (setv squares [])
        
        (setv next_sq (Square (+ self.x 1) self.y))
        (if (field.is_free next_sq)
            (.append squares next_sq)
        )

        (setv next_sq (Square (- self.x 1) self.y))
        (if (field.is_free next_sq)
            (.append squares next_sq)
        )

        (setv next_sq (Square self.x (+ self.y 1)))
        (if (field.is_free next_sq)
            (.append squares next_sq)
        )

        (setv next_sq (Square self.x (- self.y 1)))
        (if (field.is_free next_sq)
            (.append squares next_sq)
        )

        squares
    )
)

(defclass Field []
    (defn __init__ [self squares width height]
        (setv self.squares squares)
        (setv self.width width)
        (setv self.height height)
    )

    (defn is_free [self square]
        (if (do (< square.x self.width) (>= square.x 0) (< square.y self.height) (>= square.y 0))
            (do 
                (setv value (get (get self.squares square.y) square.x))
                (= value 0)
            )
            (do False)
        )
    )
)

(setv squares [])
(.append squares [1 1 0 1 1])
(.append squares [1 0 0 0 1])
(.append squares [1 1 0 0 1])
(.append squares [1 0 0 0 1])
(.append squares [1 1 1 1 1])
(setv field (Field squares 5 5))

(defclass MinimaxState []
    (defn __init__ [self score depth player_sq enemy_sq]
        (setv self.score score)
        (setv self.depth depth)
        (setv self.player_sq player_sq)
        (setv self.enemy_sq enemy_sq)
    )
)

(defclass Minimax []
    (defn __init__ [self]
        (setv self.DEPTH_LIMIT 2)
    )

    (defn evaluate [self current_sq target_sq]
        (setv a (* (- current_sq.x target_sq.x) (- current_sq.x target_sq.x)))
        (setv b (* (- current_sq.y target_sq.y) (- current_sq.y target_sq.y)))
        (** (+ a b) (/ 1 2))
    )

    (defn find_optimal_next_state [self state]
        (if (< state.depth self.DEPTH_LIMIT)
            (if (= (% state.depth 2) 0)
                (self.maximize state)
                (self.minimize state)
            )
            state
        )
    )

    (defn maximize [self state]
        (setv adjacent_squares (state.player_sq.get_adjacent_squares))
        (setv values
            (lfor adjacent_sq adjacent_squares
                (self.find_optimal_next_state (MinimaxState (self.evaluate adjacent_sq state.enemy_sq) (+ state.depth 1) adjacent_sq state.enemy_sq))
            )
        )
        (setv max_node (MinimaxState -10000 0 (Square 0 0) (Square 0 0)))
        (for [value values]
            (if (< max_node.score value.score)
                (setv max_node value)
            )
        )
        max_node
    )

    (defn minimize [self state]
        (setv adjacent_squares (state.player_sq.get_adjacent_squares))
        (setv values
            (lfor adjacent_sq adjacent_squares
                (self.find_optimal_next_state (MinimaxState (self.evaluate adjacent_sq state.player_sq) (+ state.depth 1) state.player_sq adjacent_sq))
            )
        )
        (setv min_node (MinimaxState 100000 0 (Square 0 0) (Square 0 0)))
        (for [value values]
            (if (> min_node.score value.score)
                (setv min_node value)
            )
        )
        min_node
    )
)

(setv initial_state (MinimaxState 0 0 (Square 2 0) (Square 2 3)))
(setv minimax (Minimax))
(setv next_state (minimax.find_optimal_next_state initial_state))
(print "Next move:" next_state.player_sq.x next_state.player_sq.y)

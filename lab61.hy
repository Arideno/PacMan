(import [pandas [read_csv]])

(setv df (read_csv "./results.csv"))
(setv score (get df "score"))
(setv time (get df "time"))

(defn mean_value[column]
    (/ (column.sum) (len column)))

(print "Expected time value:" (mean_value time))

(defn dispersion[column]
    (setv mean (mean_value column))
    (setv sum 0)
    (for [item (column.tolist)]
        (setv item_sum (/ (* item item) (len column)))
        (setv sum (+ sum item_sum)))
    (- sum (* mean mean)))

(print "Score dispersion value:" (dispersion score))

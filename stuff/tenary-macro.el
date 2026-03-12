(defmacro --? (predicate then else &optional input)
  "Thread last ternary operator macro.
If INPUT is provided, apply PREDICATE to INPUT.
If INPUT is nil, evaluate PREDICATE directly as a condition.
Return THEN if true, ELSE if false."
  (if input
      `(if (funcall ,predicate ,input) ,then ,else)
    `(if ,predicate ,then ,else)))

(defmacro -?- (input predicate then else)
  "Thread first ternary operator macro.
If INPUT is provided, apply PREDICATE to INPUT.
If INPUT is nil, evaluate PREDICATE directly as a condition.
Return THEN if true, ELSE if false."
  `(if (funcall ,predicate ,input) ,then ,else))

(-? 'cl-evenp "even" "odd" 3)
(?- 3 'cl-evenp "even" "odd")

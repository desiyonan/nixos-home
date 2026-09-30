;; Managed by NixOS (mesh/dotfs/uim)
;; 开/关中文：Ctrl+Space / F12
;; 上屏：Enter / Space；下一/上一候选：小键盘右/左；翻页：PgUp/PgDn / 小键盘上/下
;; 注：uim 无 KP_* 符号，TTY 小键盘方向键与 left/right/up/down 相同；
;;     Space 不作 next-candidate（generic 先判 next 再判 commit，否则无法上屏）
(define generic-on-key '("<Control> " "F12"))
(define generic-on-key? (make-key-predicate '("<Control> " "F12")))
(define generic-off-key '("<Control> " "F12"))
(define generic-off-key? (make-key-predicate '("<Control> " "F12")))
(define generic-begin-conv-key '(" "))
(define generic-begin-conv-key? (make-key-predicate '(" ")))
(define generic-commit-key '(" " generic-return-key))
(define generic-commit-key? (make-key-predicate '(" " generic-return-key?)))
(define generic-cancel-key '("escape" "<Control>[" "<IgnoreCase><Control>g"))
(define generic-cancel-key? (make-key-predicate '("escape" "<Control>[" "<IgnoreCase><Control>g")))
(define generic-next-candidate-key '("right"))
(define generic-next-candidate-key? (make-key-predicate '("right")))
(define generic-prev-candidate-key '("left"))
(define generic-prev-candidate-key? (make-key-predicate '("left")))
(define generic-next-page-key '("next" "down"))
(define generic-next-page-key? (make-key-predicate '("next" "down")))
(define generic-prev-page-key '("prior" "up"))
(define generic-prev-page-key? (make-key-predicate '("prior" "up")))

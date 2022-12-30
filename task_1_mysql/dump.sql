DROP TABLE IF EXISTS `motorcycle_type`;
DROP TABLE IF EXISTS `types`;
DROP TABLE IF EXISTS `motorcycles`;

CREATE TABLE `motorcycles`
(
    `id`              bigint unsigned NOT NULL AUTO_INCREMENT,
    `name`            varchar(255)    NOT NULL,
    `is_discontinued` tinyint(1)      NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`)
);

INSERT INTO `motorcycles` (`id`, `name`, `is_discontinued`)
VALUES (1, 'Suzuki GSX-R 1000', 0),
       (2, 'Honda CBR 1000RR', 0),
       (3, 'Yamaha YZF-R1', 0),
       (4, 'Honda CBR600RR', 0),
       (5, 'Kawasaki Ninja ZX-6RR', 0),
       (6, 'Triumph Daytona 675', 0),
       (7, 'Yamaha YZF-R6', 0),
       (8, 'Harley-Davidson V-Rod', 0),
       (9, 'Yamaha V-Max', 0),
       (10, 'BMW G650 X', 0);

CREATE TABLE `types`
(
    `id`   bigint unsigned NOT NULL AUTO_INCREMENT,
    `name` varchar(255)    NOT NULL,
    PRIMARY KEY (`id`)
);
INSERT INTO `types` (`id`, `name`)
VALUES (1, 'Классика'),
       (2, 'Спортивные'),
       (3, 'Супербайк'),
       (4, 'Круизер'),
       (5, 'Дрэгстер'),
       (6, 'Мотард'),
       (7, 'Минибайк'),
       (8, 'Тяжёлый мотоцикл'),
       (9, 'Эндуро'),
       (10, 'Мотард'),
       (11, 'Супермотард'),
       (12, 'Триал'),
       (13, 'Питбайк');


CREATE TABLE `motorcycle_type`
(
    `motorcycle_id` bigint unsigned NOT NULL,
    `type_id`       bigint unsigned NOT NULL,
    PRIMARY KEY (`motorcycle_id`, `type_id`),
    CONSTRAINT `motorcycle_type_motorcycles_id_fk` FOREIGN KEY (`motorcycle_id`) REFERENCES `motorcycles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `motorcycle_type_types_id_fk` FOREIGN KEY (`type_id`) REFERENCES `types` (`id`) ON DELETE CASCADE
);

INSERT INTO `motorcycle_type` (`motorcycle_id`, `type_id`)
VALUES (1, 1),
       (2, 1),
       (3, 2),
       (4, 2),
       (5, 3),
       (6, 4),
       (7, 4),
       (8, 5),
       (9, 5),
       (10, 5);

# Нужно отобразить все типы и кол-во мотоциклов в каждом типе и учесть,
# что мотоцикл может быть уже снят с производства.

#----------------------------
# --- ИЗНАЧАЛЬНЫЙ ВАРИАНТ ---
#----------------------------
SELECT types.name       AS type_name,
       IFNULL(count, 0) AS motorcycle_count
FROM types
         LEFT JOIN (SELECT type_id,
                           count(type_id) AS count
                    FROM motorcycle_type
                    WHERE motorcycle_type.motorcycle_id IN (SELECT id
                                                            FROM motorcycles
                                                            WHERE motorcycles.is_discontinued = 0)
                    GROUP BY type_id) AS refs ON types.id = refs.type_id;


#------------------------
# --- ПОСЛЕ ДОРАБОТКИ ---
#------------------------
SELECT t.name      type_name,
       count(m.id) motorcycle_count
FROM types t
         LEFT OUTER JOIN motorcycle_type mt ON mt.type_id = t.id
         LEFT OUTER JOIN motorcycles m ON m.id = mt.motorcycle_id
    AND m.is_discontinued = 0
GROUP BY t.name;

# ps: еще можно предположить, что у нас связь 1-m (а я подразумевал,
# что один мотоцикл может быть в нескольких категориях сразу m-m),
# но если такого быть не может,
#
# тогда можно в таблицу `motorcycles` добавить колонку type_id
# чтобы было так: (`id`, `name`, `is_discontinued`, `type_id`)
# от связующей таблицы `motorcycle_type` вовсе отказаться и получится такой запрос:
#------------------------
# SELECT t.name      type_name,
#        count(m.id) motorcycle_count
# FROM types t
#          LEFT OUTER JOIN motorcycles m ON m.type_id = t.id
#     AND m.is_discontinued = 0
# GROUP BY t.name;
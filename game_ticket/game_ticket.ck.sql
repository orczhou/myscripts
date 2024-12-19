WITH
  t_no_seat_virtual AS (
    select
      train_id as t_id,
      departure_station as d_s,
      arrival_station as a_s,
      seat_count,
      seat_count*0.1 as seat_count_no_seat
    from train
  ),
  t_include_no_seat AS (
    select t_id,d_s ,a_s ,seat_count, 0 as if_no_seat
    from t_no_seat_virtual
    union all -- 必须有 all
    select t_id,d_s ,a_s ,seat_count_no_seat, 1 as if_no_seat
    from t_no_seat_virtual
  )
SELECT
  p_01.p_id,         -- output 01
  p_01.d_s,          -- output 02
  p_01.a_s,          -- output 03
  t_01.t_id as t_id, -- output 04
  IF(
      if_no_seat,
      '' ,
      toString(ceil((p_01.seq-t_01.p_seat_to + t_01.seat_count)/100))
  ) as t_carr_id, -- output 05

  multiIf(
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = 1,
    CONCAT( ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)/5) ,'A'),
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = 2,
    CONCAT( ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)/5) ,'B'),
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = 3,
    CONCAT( ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)/5) ,'C'),
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = 4,
    CONCAT( ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)/5) ,'E'),
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = 0,
    CONCAT( IF( (p_01.seq-t_01.p_seat_to + t_01.seat_count)%100 = 0, '20' ,toString(ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)/5))) ,'F'),
    IF( (not isnull(t_01.t_id)) and if_no_seat,-1,ceil((( p_01.seq-t_01.p_seat_to + t_01.seat_count )%100)%5)) = -1,
    '无座',
    '' -- else NULL to ''
  ) as seat_index   -- output 06

FROM
  (
    select
      ROW_NUMBER() over(PARTITION BY departure_station,arrival_station) as seq ,
      passenger_id as p_id,
      departure_station as d_s,
      arrival_station as a_s
    from
    passenger
  ) as p_01

  LEFT JOIN

  (
    select
      seat_count,
      sum(seat_count)
        over (
               PARTITION BY d_s,a_s
               ORDER BY     if_no_seat,t_id
             ) as p_seat_to ,
      t_id,
      d_s ,
      a_s ,
      if_no_seat
    from
    t_include_no_seat
  ) t_01

  ON
        p_01.seq >= p_seat_to-seat_count + 1
    and p_01.seq <= p_seat_to
    and p_01.d_s =  t_01.d_s
    and p_01.a_s =  t_01.a_s
ORDER BY p_01.p_id

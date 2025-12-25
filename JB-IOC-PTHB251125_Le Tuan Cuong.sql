CREATE DATABASE CSDL1;
CREATE SCHEMA module1;
set search_path to module1;
--Tao bang
CREATE TABLE Customers(
    customer_id	VARCHAR(5) PRIMARY KEY,
    customer_full_name	VARCHAR(100) NOT NULL ,
    customer_email	VARCHAR(100) UNIQUE NOT NULL ,
    customer_phone	VARCHAR(15) NOT NULL ,
    customer_address VARCHAR(255) NOT NULL
);

CREATE TABLE Room(
        room_id	VARCHAR(5) PRIMARY KEY ,
        room_type	VARCHAR(50) NOT NULL ,
        room_price	DECIMAL(10, 2) NOT NULL ,
        room_status	VARCHAR(20) NOT NULL ,
        room_area	INT NOT NULL
);

CREATE TABLE Booking(
        booking_id	SERIAL PRIMARY KEY ,
        customer_id	VARCHAR(5) references Customers(customer_id),
        room_id	VARCHAR(5) references Room(room_id),
        check_in_date	DATE NOT NULL ,
        check_out_date	DATE NOT NULL ,
        total_amount	DECIMAL(10, 2)
);

CREATE TABLE Payment(
        payment_id	SERIAL PRIMARY KEY,
        booking_id	INT references Booking(booking_id),
        payment_method	VARCHAR(50) NOT NULL ,
        payment_date	DATE NOT NULL ,
        payment_amount	DECIMAL(10, 2) NOT NULL
);


--Chen du lieu
INSERT INTO Customers(customer_id, customer_full_name, customer_email, customer_phone, customer_address)
VALUES('C001','Nguyen Anh Tu','tu.nguyen@example.com','0912345678','Hanoi, Vietnam'),
      ('C002','Tran Thi Mai','mai.tran@example.com','0923456789','Ho Chi Minh, Vietnam'),
      ('C003','Le Minh Hoang','hoang.le@example.com','0934567890','Danang, Vietnam'),
      ('C004','Pham Hoang Nam','nam.pham@example.com','0945678901','Hue, Vietnam'),
      ('C005','Vu Minh Thu','thu.vu@example.com','0956789012','Hai Phong, Vietnam');

INSERT INTO Room(room_id, room_type, room_price, room_status, room_area)
VALUES('R001','Single',100.0,'Available',25),
      ('R002','Double',150.0 ,'Booked',40),
      ('R003','Suite',250.0,'Available',60),
      ('R004','Single',120.0,'Booked',30),
      ('R005','Double',160.0,'Available',35);

INSERT INTO Booking(booking_id,customer_id,room_id,check_in_date,check_out_date)
VALUES(1,'C001','R001','2025-03-01','2025-03-05'),
      (2,'C002','R002','2025-03-02','2025-03-06'),
      (3,'C003','R003','2025-03-03','2025-03-07'),
      (4,'C004','R004','2025-03-04','2025-03-08'),
      (5,'C005','R005','2025-03-05','2025-03-09');

INSERT INTO Payment(payment_id,booking_id, payment_method, payment_date, payment_amount)
VALUES (1,1,'Cash','2025-03-05',400.0),
       (2,2,'Credit Card','2025-03-06',600.0),
       (3,3,'Bank Transfer','2025-03-07',1000.0),
       (4,4,'Cash','2025-03-08',480.0),
       ( 5,5,'Credit Card','2025-03-09',800.0);

--Viết câu lệnh UPDATE để cập nhật lại total_amount trong bảng Booking theo công thức: total_amount = total_amount * 0.9 cho những bản ghi có ngày check_in trước ngày 3/3/2025
UPDATE Booking
set total_amount = total_amount * 0.9
where check_in_date < '2025-03-03';

--Viết câu lệnh DELETE để xóa các thanh toán trong bảng Payment
DELETE FROM Payment
where payment_method = 'Cash' AND payment_amount < 500;

--Truy van du lieu
--Lấy thông tin khách hàng gồm: mã khách hàng, họ tên, email, số điện thoại được sắp xếp theo họ tên khách hàng giảm dần.
SELECT customer_id,customer_full_name, customer_email, customer_phone
FROM Customers
ORDER BY customer_full_name DESC;
--Lấy thông tin các phòng khách sạn gồm: mã phòng, loại phòng, giá phòng và diện tích phòng, sắp xếp theo diện tích phòng tăng dần
SELECT room_id,room_type, room_price, room_area
FROM Room
ORDER BY room_area;
--Lấy thông tin khách hàng và phòng khách sạn đã đặt gồm: họ tên khách hàng, mã phòng, ngày nhận phòng và ngày trả phòng.
SELECT c.customer_full_name, b.room_id, b.check_in_date, b.check_out_date
    FROM Customers c
Join Booking b on c.customer_id = b.customer_id;
--Lấy danh sách khách hàng và tổng tiền đã thanh toán khi đặt phòng, gồm mã khách hàng, họ tên khách hàng, phương thức thanh toán và số tiền thanh toán, sắp xếp theo số tiền thanh toán tăng dần.
SELECT c.customer_id,c.customer_full_name,p.payment_method, sum(p.payment_amount) as so_tien_thanh_toan
    FROM Customers c
    JOIN Booking b on c.customer_id = b.customer_id
JOIN Payment p on b.booking_id = p.booking_id
GROUP BY c.customer_id, c.customer_full_name, p.payment_method
ORDER BY so_tien_thanh_toan;
--Lấy tất cả thông tin khách hàng từ vị trí thứ 2 đến thứ 4 trong bảng Customer được sắp xếp theo tên khách hàng (Z-A).
SELECT * FROM Customers
ORDER BY customer_full_name DESC
LIMIT 3
OFFSET 1;

--Lấy danh sách khách hàng đã đặt ít nhất 2 phòng gồm : mã khách hàng, họ tên khách hàng và số lượng phòng đã đặt.
SELECT c.customer_id, c.customer_full_name, count(DISTINCT B.room_id) AS So_luong_phong_da_dat
    FROM Customers c
    JOIN Booking B on c.customer_id = B.customer_id
JOIN Room R on R.room_id = B.room_id
GROUP BY c.customer_id, c.customer_full_name
HAVING count(DISTINCT B.room_id) >= 2;

--Lấy danh sách các phòng từng có ít nhất 3 khách hàng đặt, gồm mã phòng, loại phòng, giá phòng và số lần đã đặt.
SELECT r.room_id, r.room_type, r.room_price, COUNT(B.customer_id)
    FROM Room r
JOIN Booking B on r.room_id = B.room_id
GROUP BY r.room_id, r.room_type, r.room_price
HAVING COUNT(b.customer_id) >= 3;

--Lấy danh sách các khách hàng có tổng số tiền đã thanh toán lớn hơn 1000, gồm mã khách hàng, họ tên khách hàng, mã phòng, tổng số tiền đã thanh toán.
SELECT c.customer_id,c.customer_full_name,r.room_id, SUM(p.payment_amount) as tongtienthanhtoan
    FROM Customers c
    JOIN Booking B on c.customer_id = B.customer_id
    JOIN Payment P on B.booking_id = P.booking_id
    JOIN Room r on r.room_id = B.room_id
    GROUP BY c.customer_id,customer_full_name,r.room_id
    HAVING SUM(p.payment_amount) > 1000;
-- Lấy danh sách các khách hàng gồm : mã KH, Họ tên, email, sđt có họ tên chứa chữ "Minh" hoặc địa chỉ ở "Hanoi". Sắp xếp kết quả theo họ tên tăng dần.
SELECT customer_id,customer_full_name,customer_email,customer_phone
    FROM Customers
WHERE customer_full_name LIKE '% Minh %' OR customer_address LIKE 'Hanoi%'
ORDER BY customer_full_name;
--Lấy danh sách thông tin các phòng gồm : mã phòng, loại phòng, giá , sắp xếp theo giá phòng giảm dần.Chỉ lấy 5 phòng và bỏ qua 5 phòng đầu tiên (tức là lấy kết quả của trang thứ 2, biết mỗi trang có 5 phòng).
SELECT room_id,room_type,room_price
FROM Room
ORDER BY room_price
LIMIT 5
OFFSET 5;

--Tao View
-- tạo một view để lấy thông tin các phòng và khách hàng đã đặt, với điều kiện ngày nhận phòng nhỏ hơn ngày 2025-03-04. Cần hiển thị các thông tin sau: Mã phòng, Loại phòng, Mã khách hàng, họ tên khách hàng
CREATE VIEW v_customer_booking as
    SELECT r.room_id, r.room_type, c.customer_id, c.customer_full_name
        FROM Room r
    JOIN Booking B on r.room_id = B.room_id
JOIN Customers C on C.customer_id = B.customer_id
WHERE b.check_in_date < '2025-03-04'
GROUP BY r.room_id, r.room_type, c.customer_id, c.customer_full_name;
--Hãy tạo một view để lấy thông tin khách hàng và phòng đã đặt, với điều kiện diện tích phòng lớn hơn 30 m². Cần hiển thị các thông tin sau: Mã khách hàng, Họ tên khách hàng, Mã phòng, Diện tích phòng, Ngày nhận phòng
CREATE VIEW v_customer_room as
    SELECT c.customer_id,c.customer_full_name, r.room_id, r.room_area, b.check_in_date
        FROM Customers c JOIN Booking B on c.customer_id = B.customer_id
        JOIN Room R on R.room_id = B.room_id
WHERE r.room_area > 30;

--Tao Trigger
--Hãy tạo một trigger check_insert_booking để kiểm tra dữ liệu mối khi chèn vào bảng Booking. Kiểm tra nếu ngày đặt phòng mà sau ngày trả phòng thì thông báo lỗi với nội dung “Ngày đặt phòng không thể sau ngày trả phòng được !” và hủy thao tác chèn dữ liệu vào bảng
CREATE OR REPLACE FUNCTION check_insert_booking()
RETURNS TRIGGER as $$
    BEGIN
        if NEW.check_in_date > NEW.check_out_date THEN
            RAISE EXCEPTION 'Ngày đặt phòng không thể sau ngày trả phòng được !';
        end if;
        return new;
end;
$$ language plpgsql;

CREATE TRIGGER trg_insert_booking
BEFORE INSERT ON Booking
For EACH ROW
EXECUTE FUNCTION check_insert_booking();

-- Tạo một trigger có tên là update_room_status_on_booking để tự động cập nhật trạng thái phòng thành "Booked" khi một phòng được đặt (khi có bản ghi được INSERT vào bảng Booking).
CREATE OR REPLACE FUNCTION update_room_status_on_booking()
    RETURNS TRIGGER as $$
BEGIN
    UPDATE Room
    SET room_status = 'Booked'
    WHERE room_id = new.room_id;
RETURN NEW;
end;
$$ language plpgsql;

CREATE TRIGGER trg_update_room_status
    AFTER INSERT ON Booking
    For EACH ROW
EXECUTE FUNCTION update_room_status_on_booking();

--StoreProcedure
--Viết store procedure có tên add_customer để thêm mới một khách hàng với đầy đủ các thông tin cần thiết
CREATE OR REPLACE PROCEDURE add_customer(
    a_customer_id varchar(5),
    a_customer_full_name varchar(100),
    a_customer_email varchar(100),
    a_customer_phone varchar(15),
    a_customer_address varchar(255)
) language plpgsql
as $$
    BEGIN
        insert into Customers (customer_id, customer_full_name, customer_email, customer_phone, customer_address)
        VALUES (a_customer_id,a_customer_full_name,a_customer_email,a_customer_phone,a_customer_address);
        RAISE NOTICE 'Da them khach hang';
        end;
    $$;
CALL add_customer(a_customer_id := 'C007', a_customer_full_name := 'Le Tuan Cuong', a_customer_email := 'cuongjap208@gmail.com', a_customer_phone := '0399149270', a_customer_address := 'Hanoi');

--Hãy tạo một Stored Procedure  có tên là add_payment để thực hiện việc thêm một thanh toán mới cho một lần đặt phòng.
CREATE OR REPLACE PROCEDURE add_payment(
    p_booking_id int,
    p_payment_method varchar(50),
    p_payment_amount numeric(10,2),
    p_payment_date date)
language plpgsql as $$
    BEGIN
        INSERT INTO Payment(booking_id, payment_method, payment_date, payment_amount)
        VALUES(p_booking_id,p_payment_method, p_payment_date,p_payment_amount);
    end;
    $$;




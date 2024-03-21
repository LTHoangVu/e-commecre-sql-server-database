/*Nhập vào giá tiền mà mong muốn, xuất ra danh sách sản phẩm nằm trong khoảng tiền đó, 
nếu không tồn tại trả về 0*/

CREATE PROCEDURE PROC_SP_PRICES
    @MinPrice MONEY,
    @MaxPrice MONEY
AS
BEGIN
	IF NOT EXISTS (SELECT GIA FROM SANPHAM WHERE GIA BETWEEN @MinPrice AND @MaxPrice)
		RETURN 0
	ELSE
	BEGIN
		SELECT * FROM SANPHAM
		WHERE GIA BETWEEN @MinPrice AND @MaxPrice
	END
END
GO
---- 2.1. THỰC THI VÀ KIỂM TRA
DECLARE @MinPrice MONEY, @MaxPrice MONEY
SET @MinPrice = 100000
SET @MaxPrice = 200000
EXEC PROC_SP_PRICES @MinPrice, @MaxPrice 

---- 2.2. XÓA
DROP PROC PROC_SP_PRICES
GO 

/*Nhập vào mã một sản phẩm, xuất ra danh sách gợi ý các sản phẩm khác 
cùng danh mục, nếu tên sản phẩm không tồn tại thì trả về 0*/

CREATE PROC PROC_GOIY_DANHMUC
	@masp CHAR(6)
AS
BEGIN 
	DECLARE @danhmuc NVARCHAR(50)
	SELECT @danhmuc = SP.DANHMUC FROM SANPHAM SP WHERE @masp = MASP
	IF NOT EXISTS (SELECT * FROM SANPHAM WHERE @masp = MASP)
		RETURN 0
	ELSE
	BEGIN
		SELECT * FROM SANPHAM SP WHERE SP.DANHMUC = @danhmuc 
		EXCEPT 
		SELECT * FROM SANPHAM SP WHERE SP.MASP = @masp;
	END
END
GO
---- 3.1. THỰC THI VÀ KIỂM TRA
DECLARE @masp CHAR(6)
SET @masp = 'SP0001'
EXEC PROC_GOIY_DANHMUC @masp

---- 3.2. XÓA
DROP PROC PROC_GOIY_DANHMUC
GO 


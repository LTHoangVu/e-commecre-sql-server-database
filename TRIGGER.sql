﻿/* Tổng tiền = SL * Gia từng sản phẩm */
-- CODE
CREATE TRIGGER trg_ctdhins ON dbo.CTDH
FOR INSERT
AS
BEGIN
	DECLARE @MSP char(6), @SL int, @MDH char(6), @TTIEN money
	SELECT @MSP = MASP, @SL = SL, @MDH = MADH from inserted
	SELECT @TTIEN = SUM(@SL * GIA) FROM inserted, sanpham AS SP
	WHERE SP.MASP = @MSP GROUP BY MADH
	UPDATE DONHANG SET GIASPBD = GIASPBD + @TTIEN
	WHERE MADH = @MDH
END
GO


CREATE TRIGGER trg_ctdhdel ON dbo.CTDH
FOR DELETE
AS
BEGIN
	DECLARE @MSP char(6), @SL int, @MDH char(6), @TTIEN money
	SELECT @MSP = MASP, @SL = SL, @MDH = MADH from deleted
	SELECT @TTIEN = SUM(@SL * GIA) FROM deleted, sanpham AS SP
	WHERE SP.MASP = deleted.MASP GROUP BY MADH
	UPDATE DONHANG SET GIASPBD = GIASPBD - @TTIEN
	WHERE MADH = @MDH
END
GO


CREATE TRIGGER trg_ctdhupd ON dbo.CTDH
FOR UPDATE
AS
BEGIN
	DECLARE @MSP char(6), @SL int, @MDH char(6), @TTIEN money
	SELECT @MSP = MASP, @SL = SL, @MDH = MADH from inserted
	SELECT @TTIEN = SUM(@SL * GIA) FROM inserted, sanpham AS SP
	WHERE SP.MASP = inserted.MASP GROUP BY MADH
	UPDATE DONHANG SET GIASPBD = GIASPBD + @TTIEN
	WHERE MADH = @MDH
END
GO



/*
Trigger ràng buộc các điều kiện sau
- Hóa đơn dưới 100k không được áp dụng voucher
- Hóa đơn từ 100k - 200k chỉ được áp dụng voucher vận
chuyển
- Hóa đơn trên 300k áp dụng được cả voucher của shop &
vận chuyển
*/
-- CODE
CREATE TRIGGER VCINS_DH ON dbo.DONHANG
FOR INSERT
AS
BEGIN
	DECLARE @MDH CHAR(6), @VCVC CHAR(6), @VCS CHAR(6), @TIEN MONEY
	SELECT @MDH = MADH, @VCVC = VOUCHERVC, @VCS = VOUCHERSHOP, @TIEN = GIASPBD FROM inserted
	IF (@TIEN < 100000 AND (@VCVC IS NOT NULL OR @VCS IS NOT NULL))
	BEGIN
		PRINT N'ĐƠN HÀNG DƯỚI 100K KHÔNG ĐƯỢC ÁP DỤNG VOUCHER'
		ROLLBACK TRAN
	END
	ELSE IF ((@TIEN BETWEEN 100000 AND 200000) AND @VCS IS NOT NULL)
	BEGIN
		PRINT N'ĐƠN HÀNG TỪ 100K - 200K KHÔNG ĐƯỢC ÁP DỤNG VOUCHERSHOP'
		ROLLBACK TRAN
	END
	ELSE
		PRINT N'THÊM 1 ĐƠN HÀNG THÀNH CÔNG'
END
GO


CREATE TRIGGER VCUPD_DH ON dbo.DONHANG
FOR UPDATE
AS
BEGIN
	DECLARE @MDH CHAR(6), @VCVC CHAR(6), @VCS CHAR(6), @TIEN MONEY
	SELECT @MDH = MADH, @VCVC = VOUCHERVC, @VCS = VOUCHERSHOP, @TIEN = GIASPBD FROM inserted
	IF (@TIEN < 100000 AND (@VCVC IS NOT NULL OR @VCS IS NOT NULL))
	BEGIN
		PRINT N'ĐƠN HÀNG DƯỚI 100K KHÔNG ĐƯỢC ÁP DỤNG VOUCHER'
		ROLLBACK TRAN
	END
	ELSE IF ((@TIEN BETWEEN 100000 AND 200000) AND @VCS IS NOT NULL)
	BEGIN
		PRINT N'ĐƠN HÀNG TỪ 100K - 200K KHÔNG ĐƯỢC ÁP DỤNG VOUCHERSHOP'
		ROLLBACK TRAN
	END
	ELSE
		PRINT N'UPDATE 1 ĐƠN HÀNG THÀNH CÔNG'
END
GO



/* Trigger chỉ được khiếu nại đơn hàng dưới 7 ngày tính từ ngày nhận */
-- CODE

CREATE TRIGGER KNUPD_DH ON dbo.DONHANG
FOR UPDATE
AS
BEGIN
	DECLARE @MDH CHAR(6), @NGNHAN SMALLDATETIME, @NGLAP SMALLDATETIME
	SELECT @MDH = MADH, @NGNHAN = NGAYGIAOTC FROM inserted
	SELECT @NGLAP = NGAYLAP FROM DonKhieuNaiHoanTien
	WHERE DONHANG = @MDH
	IF (DATEDIFF(DAY, @NGNHAN, @NGLAP) > 7)
	BEGIN
		PRINT N'NGÀY LẬP ĐƠN KHIẾU NẠI KHÔNG ĐƯỢC QUÁ 7 NGÀY SO VỚI NGÀY NHẬN'
		ROLLBACK TRAN
	END
END
GO


CREATE TRIGGER KNINS_KN ON dbo.DonKhieuNaiHoanTien
FOR INSERT
AS
BEGIN
	DECLARE @MDH CHAR(6), @NGNHAN SMALLDATETIME, @NGLAP SMALLDATETIME
	SELECT @MDH = DONHANG, @NGLAP = NGAYLAP FROM inserted
	SELECT @NGNHAN = NGAYGIAOTC FROM DONHANG WHERE MADH = @MDH
	IF (DATEDIFF(DAY, @NGNHAN, @NGLAP) > 7)
	BEGIN
		PRINT N'NGÀY LẬP ĐƠN KHIẾU NẠI KHÔNG ĐƯỢC QUÁ 7 NGÀY SO VỚI NGÀY NHẬN'
		ROLLBACK TRAN
	END
	ELSE
		PRINT N'THÊM ĐƠN KHIẾU NẠI THÀNH CÔNG'
END
GO


CREATE TRIGGER KNUPD_KN ON dbo.DonKhieuNaiHoanTien
FOR UPDATE
AS
BEGIN
	DECLARE @MDH CHAR(6), @NGNHAN SMALLDATETIME, @NGLAP SMALLDATETIME
	SELECT @MDH = DONHANG, @NGLAP = NGAYLAP FROM inserted
	SELECT @NGNHAN = NGAYGIAOTC FROM DONHANG WHERE MADH = @MDH
	IF (DATEDIFF(DAY, @NGNHAN, @NGLAP) > 7)
	BEGIN
		PRINT N'NGÀY LẬP ĐƠN KHIẾU NẠI KHÔNG ĐƯỢC QUÁ 7 NGÀY SO VỚI NGÀY NHẬN'
	ROLLBACK TRAN
	END
	ELSE
		PRINT N'UPDATE ĐƠN KHIẾU NẠI THÀNH CÔNG'
END
GO
use QuanLyDeTai


--T1. Tên đề tài phải duy nhất
CREATE TRIGGER t_unique_name_DETAI
ON DETAI
FOR insert,update
AS
if update(TENDT)
BEGIN
	IF exists(SELECT * FROM inserted AS INS WHERE EXISTS (SELECT * FROM DETAI AS DT WHERE DT.TENDT = INS.TENDT ))
	BEGIN
		raiserror(N'Lỗi vi phạm ràng buộc duy nhất cho tên đề tài',16,1)
		rollback
	END
END

go



--T2. Trưởng bộ môn phải sinh sau trước 1975

-- Sinh trước
CREATE TRIGGER t_born_before_TR_BOMON
ON BOMON
FOR insert,update
AS
if update(TRUONGBM)
BEGIN
	IF exists(SELECT * FROM inserted AS INS JOIN GIAOVIEN as GV ON GV.MAGV = INS.TRUONGBM WHERE YEAR(GV.NGSINH) <= 1975)
	BEGIN
		raiserror(N'Lỗi Trưởng bộ môn phải sinh sau năm 1975',16,1)
		rollback
	END
END

go
-- Sinh sau

CREATE TRIGGER t_born_affter_TR_BOMON
ON BOMON
FOR insert,update
AS
if update(TRUONGBM)
BEGIN
	IF exists(SELECT * FROM inserted AS INS JOIN GIAOVIEN as GV ON GV.MAGV = INS.TRUONGBM WHERE YEAR(GV.NGSINH) >= 1975)
	BEGIN
		raiserror(N'Lỗi Trưởng bộ môn sinh trước năm 1975',16,1)
		rollback
	END
END

go
--T3. Một bộ môn có tối thiểu 1 giáo viên nữ
CREATE TRIGGER t_woman_in_BOMON
ON GIAOVIEN
FOR DELETE
AS
BEGIN
	IF (EXISTS(SELECT * FROM BOMON AS BM WHERE BM.MABM IN( SELECT BM.MABM FROM BOMON AS BM JOIN GIAOVIEN as DEL ON DEL.MABM = BM.MABM WHERE DEL.PHAI = N'Nữ' GROUP BY BM.MABM)))
	BEGIN
		raiserror(N'Lỗi mỗi bộ môn phải có tối thiểu một giáo viên nữ',16,1)
		rollback
	END
END

GO

CREATE TRIGGER t_woman_in_BOMON_UPDATE
ON GIAOVIEN
FOR UPDATE
AS
IF update(PHAI)
BEGIN
	IF (EXISTS(SELECT * FROM BOMON AS BM WHERE BM.MABM IN( SELECT BM.MABM FROM BOMON AS BM JOIN GIAOVIEN as DEL ON DEL.MABM = BM.MABM WHERE DEL.PHAI = N'Nữ' GROUP BY BM.MABM)))
	BEGIN
		raiserror(N'Lỗi mỗi bộ môn phải có tối thiểu một giáo viên nữ',16,1)
		rollback
	END
END



(SELECT BM.MABM, COUNT(DEL.MAGV) FROM BOMON AS BM JOIN GIAOVIEN as DEL ON DEL.MABM = BM.MABM WHERE DEL.PHAI = N'Nữ' GROUP BY BM.MABM having count(DEL.MAGV) = 0)


GO

--T4. Một giáo viên phải có ít nhất 1 số điện thoại

CREATE TRIGGER t_PHONE_GIAOVIEN
ON GV_DT
FOR UPDATE
AS
IF update(MAGV)
BEGIN
	IF (EXISTS(SELECT * FROM GIAOVIEN AS GV1 WHERE GV1.MAGV NOT IN (SELECT GV.MAGV FROM GIAOVIEN AS GV JOIN GV_DT AS PHO ON PHO.MAGV = GV.MAGV)))
	BEGIN
		raiserror(N'Lỗi mỗi giáo viên phải có ít nhất một số điện thoại',16,1)
		rollback
	END
END

GO


CREATE TRIGGER t_PHONE_GIAOVIEN_DEL
ON GV_DT
FOR DELETE
AS
BEGIN
	IF (EXISTS(SELECT * FROM GIAOVIEN AS GV1 WHERE GV1.MAGV NOT IN (SELECT GV.MAGV FROM GIAOVIEN AS GV JOIN GV_DT AS PHO ON PHO.MAGV = GV.MAGV)))
	BEGIN
		raiserror(N'Lỗi mỗi giáo viên phải có ít nhất một số điện thoại',16,1)
		rollback
	END
END

GO


--T5. Một giáo viên có tối đa 3 số điện thoại
CREATE TRIGGER t_PHONE_GIAOVIEN_MAX
ON GV_DT
FOR insert,update
AS
if update(MAGV)
BEGIN
	IF (EXISTS(SELECT INS.MAGV FROM (GIAOVIEN AS INS join GV_DT AS PHO ON PHO.MAGV = INS.MAGV),inserted WHERE INS.MAGV = inserted.MAGV GROUP BY INS.MAGV HAVING COUNT(*) > 3))
	BEGIN
		raiserror(N'Lỗi mỗi giáo viên chỉ có thể có tối đa 3 số điện thoại',16,1)
		rollback
	END
END

GO


--T6. Một bộ môn phải có tối thiểu 4 giáo viên
CREATE TRIGGER t_number_BOMON
ON GIAOVIEN
FOR update
AS
if update(MAGV)
BEGIN
	IF ((SELECT COUNT(*) FROM (GIAOVIEN AS GV JOIN BOMON AS BM ON BM.MABM = GV.MABM),deleted WHERE BM.MABM = deleted.MABM GROUP BY BM.MABM) <4)
	BEGIN
		raiserror(N'Lỗi: mỗi bộ môn phải có ít nhất 4 thành viên',16,1)
		rollback
	END
END

GO

(SELECT BM.MABM, COUNT(DEL.MAGV) FROM BOMON AS BM JOIN GIAOVIEN as DEL ON DEL.MABM = BM.MABM WHERE DEL.PHAI = N'Nữ' GROUP BY BM.MABM having count(DEL.MAGV) = 0)




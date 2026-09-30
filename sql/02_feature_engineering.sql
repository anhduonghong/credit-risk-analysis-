
WITH base AS (
    SELECT 
        *,
        
        -- 1. BIẾN ĐỘNG DƯ NỢ GIỮA CÁC THÁNG LIỀN KỀ (DELTA BILL TOÀN BỘ 6 KỲ)
        (BILL_AMT1 - BILL_AMT2) AS BILL_DIFF_M1_M2, -- Biến động Tháng 9 vs Tháng 8
        (BILL_AMT2 - BILL_AMT3) AS BILL_DIFF_M2_M3, -- Biến động Tháng 8 vs Tháng 7
        (BILL_AMT3 - BILL_AMT4) AS BILL_DIFF_M3_M4, -- Biến động Tháng 7 vs Tháng 6
        (BILL_AMT4 - BILL_AMT5) AS BILL_DIFF_M4_M5, -- Biến động Tháng 6 vs Tháng 5
        (BILL_AMT5 - BILL_AMT6) AS BILL_DIFF_M5_M6, -- Biến động Tháng 5 vs Tháng 4
        
        -- Tổng biến động dư nợ từ đầu kỳ (T4) đến cuối kỳ (T9)
        (BILL_AMT1 - BILL_AMT6) AS BILL_DIFF_TOTAL_6M,

        -- 2. Phân nhóm độ tuổi (AGE_GROUP)
        CASE 
            WHEN AGE >= 20 AND AGE <= 29 THEN '20-29'
            WHEN AGE >= 30 AND AGE <= 39 THEN '30-39'
            WHEN AGE >= 40 AND AGE <= 49 THEN '40-49'
            WHEN AGE >= 50 AND AGE <= 59 THEN '50-59'
            ELSE '60+'
        END AS AGE_GROUP,

        -- 3. Phân nhóm học vấn (EDUCATION_LABEL)
        CASE 
            WHEN EDUCATION = 1 THEN 'Graduate School'
            WHEN EDUCATION = 2 THEN 'University'
            WHEN EDUCATION = 3 THEN 'High School'
            ELSE 'Others'
        END AS EDUCATION_LABEL,

        -- 4. Phân nhóm hôn nhân (MARRIAGE_LABEL)
        CASE 
            WHEN MARRIAGE = 1 THEN 'Married'
            WHEN MARRIAGE = 2 THEN 'Single'
            ELSE 'Others'
        END AS MARRIAGE_LABEL,

        -- 5. Phân nhóm hạn mức (LIMIT_GROUP) + Thứ tự sắp xếp (LIMIT_ORDER)
        CASE 
            WHEN LIMIT_BAL < 50000 THEN '< 50K'
            WHEN LIMIT_BAL < 100000 THEN '50K - 100K'
            WHEN LIMIT_BAL < 200000 THEN '100K - 200K'
            WHEN LIMIT_BAL < 300000 THEN '200K - 300K'
            WHEN LIMIT_BAL < 500000 THEN '300K - 500K'
            ELSE '>= 500K'
        END AS LIMIT_GROUP,
        CASE 
            WHEN LIMIT_BAL < 50000 THEN 1
            WHEN LIMIT_BAL < 100000 THEN 2
            WHEN LIMIT_BAL < 200000 THEN 3
            WHEN LIMIT_BAL < 300000 THEN 4
            WHEN LIMIT_BAL < 500000 THEN 5
            ELSE 6
        END AS LIMIT_ORDER,

        -- 6. Tỷ lệ sử dụng hạn mức (CREDIT_UTILIZATION) & Phân nhóm (UTILIZATION_GROUP)
        CASE 
            WHEN LIMIT_BAL > 0 THEN (BILL_AMT1 * 1.0) / LIMIT_BAL 
            ELSE 0.0 
        END AS CREDIT_UTILIZATION,
        CASE 
            WHEN LIMIT_BAL > 0 AND (BILL_AMT1 * 1.0) / LIMIT_BAL <= 0.30 THEN '1. Safe (< 30%)'
            WHEN LIMIT_BAL > 0 AND (BILL_AMT1 * 1.0) / LIMIT_BAL <= 0.60 THEN '2. Moderate (30-60%)'
            WHEN LIMIT_BAL > 0 AND (BILL_AMT1 * 1.0) / LIMIT_BAL <= 0.80 THEN '3. High (60-80%)'
            ELSE '4. Critical (> 80%)'
        END AS UTILIZATION_GROUP,

        -- 7. Tỷ lệ thanh toán (PAYMENT_RATIO)
        CASE 
            WHEN BILL_AMT2 > 0 THEN (PAY_AMT1 * 1.0) / BILL_AMT2
            WHEN BILL_AMT2 <= 0 AND PAY_AMT1 > 0 THEN 1.0
            ELSE 0.0
        END AS PAYMENT_RATIO,

        -- 8. Điểm trễ hạn lớn nhất (MAX_DELINQUENCY)
        GREATEST(PAY_0, PAY_2, PAY_3, PAY_4, PAY_5, PAY_6) AS MAX_DELINQUENCY,

        -- 9. Chỉ số xu hướng dư nợ so với TB 6 tháng (BILL_TREND_RATIO)
        CASE 
            WHEN (BILL_AMT1 + BILL_AMT2 + BILL_AMT3 + BILL_AMT4 + BILL_AMT5 + BILL_AMT6) > 0 
            THEN (BILL_AMT1 * 1.0) / ((BILL_AMT1 + BILL_AMT2 + BILL_AMT3 + BILL_AMT4 + BILL_AMT5 + BILL_AMT6) / 6.0)
            ELSE 0.0
        END AS BILL_TREND_RATIO,

        -- 10. Trạng thái trễ hạn tháng gần nhất (PAGE 3)
        CASE 
            WHEN PAY_0 >= 2 THEN '2+ Months Delay'
            WHEN PAY_0 = 1 THEN '1 Month Delay'
            WHEN PAY_0 = 0 THEN 'Pay Minimum/Revolving'
            ELSE 'Paid on Time / Advance'
        END AS CURRENT_PAYMENT_STATUS,

        -- 11. Cờ cảnh báo sớm (PAGE 3)
        CASE 
            WHEN PAY_0 IN (1, 2) THEN 'Early Warning (1-2M Late)'
            WHEN PAY_0 > 2 THEN 'Severe Delinquent (>2M)'
            ELSE 'Normal / Up-to-date'
        END AS EARLY_WARNING_FLAG

    FROM `[genz] uci_credit_card`
)
SELECT 
    *, 
    -- 12. Phân hạng rủi ro (RISK_TIER)
    CASE 	
        WHEN MAX_DELINQUENCY >= 2 OR CREDIT_UTILIZATION > 0.80 THEN 'High Risk'
        WHEN MAX_DELINQUENCY = 1 OR (CREDIT_UTILIZATION BETWEEN 0.50 AND 0.80) THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RISK_TIER,

    -- 13. Mức độ ưu tiên thu hồi nợ (PAGE 3)
    CASE 
        WHEN PAY_0 >= 2 AND BILL_AMT1 >= 50000 THEN 'P1 - Urgent Call (High Debt)'
        WHEN PAY_0 = 1 AND (BILL_AMT1 * 1.0 / NULLIF(LIMIT_BAL, 0)) > 0.80 THEN 'P2 - Early Call (High Util)'
        WHEN PAY_0 IN (1, 2) THEN 'P3 - SMS / Reminder'
        ELSE 'P4 - Standard Monitoring'
    END AS COLLECTION_PRIORITY,

    -- 14. Dư nợ trung bình theo nhóm tuổi
    AVG(BILL_AMT1) OVER (PARTITION BY AGE_GROUP) AS AVG_BILL_BY_AGE_GROUP
FROM base;
_mpa_site_avg =
VAR Sites =
    VALUES ( Fact_Assessment[Site] )
VAR SiteWithAvg =
    ADDCOLUMNS (
        Sites,
        "__site_avg",
            CALCULATE (
                [_mpa_program_avg],
                REMOVEFILTERS ( Fact_Assessment[Class] )
            )
    )
VAR Valid =
    FILTER (
        SiteWithAvg,
        NOT ISBLANK ( [__site_avg] ) && [__site_avg] <> 0
    )
RETURN
COALESCE ( AVERAGEX ( Valid, [__site_avg] ), 0 )



_Total_Score =
SUM ( Fact_Assessment[Score] )



_Questions_Answered_Per_Topic =
CALCULATE (
    COUNT ( Fact_Assessment[Question] ),
    FILTER (
        Fact_Assessment,
        NOT ISBLANK ( Fact_Assessment[Answer] )
            && Fact_Assessment[Score] <> 0
    )
)



_PA_Score =
DIVIDE (
    COALESCE (
        CALCULATE (
            [_Topic_Score],
            KEEPFILTERS ( Fact_Assessment[TopicCode] = "PA" )
        ),
        0
    ),
    1,
    0
)



_Hygiene_Practices_Score =
VAR s =
    SUMX (
        Fact_HealthSafety,
        VAR raw = Fact_HealthSafety[HygienePractices]
        VAR num = VALUE ( TRIM ( SUBSTITUTE ( raw, UNICHAR ( 160 ), " " ) ) )
        RETURN num
    )
RETURN
DIVIDE ( s, [Distinct_Submitter_Count], 0 )



_Student_Count =
DISTINCTCOUNT ( Fact_Student[StudentId] )



_Child_Lesson_Target =
VAR AgeInMonths =
    SELECTEDVALUE ( Fact_Student[AgeMonths] )
RETURN
IF (
    NOT ISBLANK ( AgeInMonths ),
    LOOKUPVALUE (
        Dim_Benchmark[TargetMasteredLessons],
        Dim_Benchmark[AgeMonths], AgeInMonths
    )
)
package com.everypet.keyword.model.dao;

import com.everypet.keyword.model.dto.KeywordRankDTO;
import com.everypet.keyword.model.dto.KeywordRankDTO.TopKeywordRank;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface KeywordRankMapper {

    // 키워드 랭킹을 모두 조회
    List<KeywordRankDTO> findAllKeywordRank();
    // 1~10위까지의 키워드 랭킹을 조회
    List<TopKeywordRank> findTopKeywordRank();
    void saveKeywordRank(KeywordRankDTO keyword);
    void updateTotalScore(KeywordRankDTO keyword);
    void updateRanking(KeywordRankDTO keyword);
    KeywordRankDTO findKeywordRank(String keyword);
    void deleteRecordsWithZeroScore();

    void resetOneHourScore();
    void resetDailyScore();
    void resetWeeklyScore();

}
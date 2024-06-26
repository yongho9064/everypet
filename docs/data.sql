CREATE TABLE TBL_MEMBER
(
    MEMBER_ID          VARCHAR(50)  NOT NULL PRIMARY KEY, # 회원 아이디
    MEMBER_PWD         VARCHAR(255) NOT NULL, # 회원 비밀번호
    NAME               VARCHAR(20)  NOT NULL, # 회원 이름
    EMAIL              VARCHAR(50)  NOT NULL, # 회원 이메일
    PHONE              VARCHAR(13)  NOT NULL, # 회원 전화번호
    LEVEL              VARCHAR(30) DEFAULT 'NEW', # 회원 등급
    POINT              BIGINT      DEFAULT 0, # 회원 포인트
    AGREE_MARKETING_YN CHAR(1)     DEFAULT 'N', # 마케팅 동의 여부
    ACC_INACTIVE_YN    CHAR(1)     DEFAULT 'N', # 회원 탈퇴 여부
    TEMP_PWD_YN        CHAR(1)     DEFAULT 'N', # 임시 비밀번호 여부
    ACC_LOGIN_COUNT    BIGINT      DEFAULT 0, # 로그인 횟수
    LOGIN_FAIL_COUNT   BIGINT      DEFAULT 0, # 로그인 실패 횟수
    LAST_LOGIN_DATE    DATETIME, # 마지막 로그인 날짜
    ACC_REGISTER_DATE  DATETIME    DEFAULT CURRENT_TIMESTAMP, # 회원 가입 날짜
    ACC_UPDATE_DATE    DATETIME, # 회원 정보 수정 날짜
    ACC_DELETE_DATE    DATETIME # 회원 탈퇴 날짜
);

CREATE TABLE TBL_ADDRESS
(
    MEMBER_ID  VARCHAR(20)  NOT NULL, # 회원 아이디
    ADDRESS    VARCHAR(255) NOT NULL, # 주소
    RECEIVER   VARCHAR(20)  NOT NULL, # 받는 사람
    PHONE      VARCHAR(13)  NOT NULL, # 전화번호
    REQUEST    VARCHAR(255), # 요청사항
    DEFAULT_YN CHAR(1)      NOT NULL DEFAULT 'N', # 기본 배송지 여부
    FOREIGN KEY (MEMBER_ID) REFERENCES TBL_MEMBER (MEMBER_ID)
);

CREATE TABLE TBL_PRODUCT(
                            PRODUCT_ID VARCHAR(50) NOT NULL PRIMARY KEY, # 상품 아이디, 이미지 주소 공통 사용
                            MEMBER_ID VARCHAR(255) NOT NULL, # 판매자 아이디
                            PRODUCT_NAME VARCHAR(255) NOT NULL, # 상품 이름
                            PRODUCT_PRICE INT NOT NULL, # 상품 가격
                            PRODUCT_REGISTRATION_DATE DATETIME NOT NULL DEFAULT NOW(), # 상품 등록 날짜
                            PRODUCT_CHANGED_DATE DATE, # 상품 수정 날짜
                            PRODUCT_SALES_STATUS_YN CHAR(1) NOT NULL DEFAULT 'Y', # 상품 판매 여부
                            PRODUCT_DISCOUNT_RATE INT NOT NULL DEFAULT 0, # 상품 할인율
                            NUMBER_OF_PRODUCT BIGINT NOT NULL  DEFAULT 0, # 상품 수량
                            PRODUCT_VIEWS BIGINT NOT NULL DEFAULT 0, # 상품 조회수
                            PRODUCT_CATEGORY VARCHAR(50) NOT NULL, # 상품 카테고리
                            FOREIGN KEY (MEMBER_ID) REFERENCES TBL_MEMBER(MEMBER_ID)
);

CREATE TABLE TBL_CART(
                         MEMBER_ID VARCHAR(50) NOT NULL, # 회원 아이디
                         PRODUCT_ID VARCHAR(50) NOT NULL, # 상품 아이디
                         CART_QUANTITY INT NOT NULL, # 상품 수량
                         PRIMARY KEY (MEMBER_ID, PRODUCT_ID),  # 복합키
                         FOREIGN KEY (MEMBER_ID) REFERENCES TBL_MEMBER (MEMBER_ID),
                         FOREIGN KEY (PRODUCT_ID) REFERENCES TBL_PRODUCT (PRODUCT_ID)
);

CREATE TABLE TBL_ROLE
(
    MEMBER_ID   VARCHAR(50) NOT NULL, # 회원 아이디
    AUTHORITIES VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER', # 권한
    PRIMARY KEY (MEMBER_ID, AUTHORITIES),
    FOREIGN KEY (MEMBER_ID) REFERENCES TBL_MEMBER (MEMBER_ID)
);

CREATE TABLE TBL_ADVERTISEMENTS (
                                    ADVERTISEMENT_ID VARCHAR(50) PRIMARY KEY, -- 광고 아이디 (프라이머리 키)
                                    MEMBER_ID VARCHAR(50) NOT NULL, -- 광고주
                                    ADVERTISEMENT_START_DATE DATE NOT NULL, -- 광고 시작 날짜
                                    ADVERTISEMENT_END_DATE DATE NOT NULL, -- 광고 종료 날짜
                                    ADVERTISEMENT_STATUS_YN CHAR(1) NOT NULL, -- 광고 상태 여부 (Y/N)
                                    ADVERTISEMENT_SEQUENCE INT NOT NULL, -- 광고 순서
                                    FOREIGN KEY (MEMBER_ID) REFERENCES TBL_MEMBER(MEMBER_ID)
);

CREATE TABLE TBL_OAUTH2_MEMBER
(
    MEMBER_ID VARCHAR(50) NOT NULL PRIMARY KEY,
    NAME      VARCHAR(50) NOT NULL,
    EMAIL     VARCHAR(50) NOT NULL
);

CREATE TABLE TBL_OAUTH2_ROLE
(
    MEMBER_ID   VARCHAR(50) NOT NULL,
    AUTHORITIES VARCHAR(50) NOT NULL,
    FOREIGN KEY (MEMBER_ID) REFERENCES TBL_OAUTH2_MEMBER (MEMBER_ID)
);

INSERT INTO TBL_MEMBER (MEMBER_ID, MEMBER_PWD, NAME, EMAIL, PHONE, LAST_LOGIN_DATE, ACC_REGISTER_DATE, ACC_UPDATE_DATE)
VALUES ('user', '$2a$10$HdOg00x3nTNCO06RwdeiA.dsWWJlWLHpx9jM8qVnQp35H3cxjDfCy', '유저', 'abc@example.com', '010-1234-5678', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
       ('admin', '$2a$10$HdOg00x3nTNCO06RwdeiA.dsWWJlWLHpx9jM8qVnQp35H3cxjDfCy', '어드민', 'def@example.com', '010-1234-5678', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO TBL_ADDRESS (MEMBER_ID, ADDRESS, RECEIVER, PHONE, REQUEST, DEFAULT_YN)
VALUES ('user', '서울시 강남구 역삼동 123-456', '유저', '010-1234-5678', '문 앞에 놔주세요', 'Y'),
       ('admin', '서울시 강남구 역삼동 123-456', '어드민', '010-1234-5678', '문 앞에 놔주세요', 'Y');

INSERT INTO TBL_ROLE (MEMBER_ID, AUTHORITIES)
VALUES ('user', 'ROLE_USER'),
       ('admin', 'ROLE_USER'),
       ('admin', 'ROLE_ADMIN');

INSERT INTO TBL_PRODUCT (PRODUCT_ID, MEMBER_ID, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_CHANGED_DATE, PRODUCT_CATEGORY)
VALUES ('c70435e6-bdd3-4c44-950c-137aad2414c4', 'user', 'Product 1', 10000, CURRENT_TIMESTAMP, 'Electronics'),
       ('e5aba346-c25d-4b86-8e6e-dcabf13ebbb0', 'user', 'Product 2', 20000, CURRENT_TIMESTAMP, 'Electronics'),
       ('e4af721a-a75c-4a7f-96bd-46c972244930', 'user', 'Product 3', 30000, CURRENT_TIMESTAMP, 'Electronics'),
       ('d1f53fba-68b8-4e92-96ec-309507fee1ff', 'user', 'Product 4', 40000, CURRENT_TIMESTAMP, 'Electronics'),
       ('9286b8fc-b40b-498f-8f8b-89926cc9e267', 'user', 'Product 5', 50000, CURRENT_TIMESTAMP, 'Electronics');

INSERT INTO TBL_CART (MEMBER_ID, PRODUCT_ID, CART_QUANTITY)
VALUES ('user', 'c70435e6-bdd3-4c44-950c-137aad2414c4', 1),
       ('user', 'e5aba346-c25d-4b86-8e6e-dcabf13ebbb0', 2),
       ('user', 'e4af721a-a75c-4a7f-96bd-46c972244930', 3),
       ('user', 'd1f53fba-68b8-4e92-96ec-309507fee1ff', 4),
       ('user', '9286b8fc-b40b-498f-8f8b-89926cc9e267', 5);

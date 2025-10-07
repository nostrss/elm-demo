# Main.elm 코드 설명

## 개요

이 Elm 애플리케이션은 Korean JSON API를 사용하여 게시글 목록과 상세 페이지를 표시하는 SPA(Single Page Application)입니다.

## 주요 구성 요소

### 1. Main 함수 (17-26행)

```elm
main : Program () Model Msg
main =
    Browser.application
```

- `Browser.application`을 사용하여 URL 라우팅을 지원하는 웹 애플리케이션 생성
- `onUrlChange`와 `onUrlRequest`로 URL 변경 감지

### 2. Model (32-58행)

#### Post 타입
```elm
type alias Post =
    { id : Int
    , title : String
    , content : String
    , userId : Int
    , createdAt : String
    }
```
게시글 데이터 구조를 정의합니다.

#### Model 타입
```elm
type alias Model =
    { key : Nav.Key
    , page : Page
    , posts : WebData (List Post)
    , postDetail : WebData Post
    }
```
- `key`: 브라우저 네비게이션 키
- `page`: 현재 페이지 상태
- `posts`: 게시글 목록 데이터
- `postDetail`: 게시글 상세 데이터

#### Page 타입
```elm
type Page
    = PostListPage
    | PostDetailPage Int
    | NotFound
```
3가지 페이지 상태를 표현합니다.

#### WebData 타입
```elm
type WebData a
    = Loading
    | Success a
    | Failure
```
HTTP 요청의 상태를 표현하는 타입입니다.

### 3. URL 파싱 (102-113행)

```elm
routeParser : Parser (Page -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map PostListPage top
        , Parser.map PostDetailPage (Parser.s "post" </> Parser.int)
        ]
```

라우팅 규칙:
- `/` → PostListPage
- `/post/{id}` → PostDetailPage

### 4. Update 함수 (119-170행)

#### Msg 타입
```elm
type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotPosts (Result Http.Error (List Post))
    | GotPostDetail (Result Http.Error Post)
```

#### 주요 메시지 처리

**LinkClicked**: 링크 클릭 시 내부/외부 URL 구분하여 처리

**UrlChanged**: URL 변경 시 해당 페이지 데이터 로드
- PostListPage → fetchPosts 실행
- PostDetailPage → fetchPostDetail 실행

**GotPosts**: 게시글 목록 로드 결과 처리
- 성공 시: 최대 10개만 저장 (159행)
- 실패 시: Failure 상태로 변경

**GotPostDetail**: 게시글 상세 로드 결과 처리

### 5. HTTP 요청 (184-207행)

#### fetchPosts
```elm
fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "https://koreanjson.com/posts"
        , expect = Http.expectJson GotPosts (Decode.list postDecoder)
        }
```
모든 게시글을 가져옵니다.

#### fetchPostDetail
```elm
fetchPostDetail : Int -> Cmd Msg
fetchPostDetail id =
    Http.get
        { url = "https://koreanjson.com/posts/" ++ String.fromInt id
        , expect = Http.expectJson GotPostDetail postDecoder
        }
```
특정 ID의 게시글을 가져옵니다.

#### postDecoder
```elm
postDecoder : Decoder Post
postDecoder =
    Decode.map5 Post
        (field "id" Decode.int)
        (field "title" string)
        (field "content" string)
        (field "UserId" Decode.int)
        (field "createdAt" string)
```
JSON 응답을 Post 타입으로 디코딩합니다.

### 6. View (213-292행)

#### view 함수
```elm
view : Model -> Browser.Document Msg
```
페이지 상태에 따라 적절한 뷰를 렌더링합니다.

#### viewPostList
게시글 목록을 표시합니다:
- Loading: "Loading..." 메시지
- Failure: 에러 메시지
- Success: 게시글 목록 (ul/li로 구성)

#### viewPostItem
개별 게시글 항목을 카드 형태로 표시:
- 제목 (h3)
- 작성자 ID와 작성일

#### viewPostDetail
게시글 상세 내용을 표시:
- "← Back to list" 링크
- 제목, 작성자 정보
- 본문 내용

## 애플리케이션 흐름

1. **초기화**: URL에 따라 초기 페이지 결정 및 데이터 로드
2. **라우팅**: URL 변경 시 적절한 페이지로 전환
3. **데이터 로드**: HTTP 요청으로 API에서 데이터 가져오기
4. **렌더링**: WebData 상태에 따라 Loading/Failure/Success 뷰 표시

## 스타일링

인라인 스타일을 사용하여:
- 패딩과 마진 설정
- 테두리와 보더 레디우스
- 텍스트 색상과 데코레이션
- 폰트 패밀리와 라인 하이트

## 특징

- **타입 안전성**: Elm의 강력한 타입 시스템 활용
- **명시적 상태 관리**: WebData로 로딩/성공/실패 상태 명확히 구분
- **선언적 라우팅**: URL 파서를 통한 명확한 라우팅 규칙
- **불변성**: Elm의 불변 데이터 구조로 예측 가능한 상태 관리

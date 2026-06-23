# 모이쇼 디자인 토큰 (Flutter 매핑용)

> 원본 CSS는 `design/tokens/` 폴더에 있습니다. 아래는 Flutter `ThemeData`로 옮기기 위한 요약입니다.
> 모든 값은 모바일 420px 캔버스 기준.

## 컬러

### 브랜드
| 토큰 | HEX |
|---|---|
| primary (모이쇼 블루) | `#3B5CFF` |
| primary-hover | `#2E47E6` |
| primary-press | `#2438B8` |
| primary-soft | `#EEF2FF` |
| accent (네온 퍼플) | `#8C52FF` |
| accent-soft | `#F4EEFF` |

### 시맨틱
| 토큰 | HEX |
|---|---|
| success (민트) | `#00C781` |
| success-soft | `#E5FBF3` |
| danger (코랄) | `#FF4B4B` |
| danger-soft | `#FFECEC` |
| warning (앰버) | `#FFA722` |
| warning-soft | `#FFF6E5` |

### 텍스트 / 표면 / 보더
| 토큰 | HEX |
|---|---|
| text-strong (금액/Display) | `#161A24` |
| text-title | `#272D3B` |
| text-body | `#3C4456` |
| text-muted | `#6E7689` |
| text-disabled | `#767F92` |
| surface-page / surface-card | `#FFFFFF` |
| surface-sunken (수치 카드 배경) | `#F4F6FA` |
| border-subtle | `#EBEEF4` |
| border-default | `#DDE2EC` |
| border-strong | `#C5CCDA` |

## 타이포그래피 — Pretendard

- 패밀리: **Pretendard** (pubspec에 폰트 추가, 또는 pretendard 패키지). 금액·달성률엔 `fontFeatures: [FontFeature.tabularFigures()]`.
- 스케일(px): display-lg **34** / display **28** / heading **22** / title **18** / subtitle **16** / body **14** / caption **12** / micro **11**
- 굵기: regular 400 / medium 500 / semibold 600 / bold 700
- 자간: display `-0.02em`(≈ letterSpacing -0.68 @34px) / title `-0.01em`
- 행간(height): tight 1.2 / snug 1.35 / normal 1.5 / relaxed 1.65

## 간격 (4px 베이스)
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64`
- 화면 좌우 여백: **20**
- 카드 내부 패딩: **20**
- 리스트 아이템 간격: **12**

## 라운드 (BorderRadius)
mini **6** / sm **8** / md **12**(입력·버튼) / lg **16** / xl **20**(카드) / 2xl **24**(메인 보드) / pill **999** / full(원)

## 섀도 (BoxShadow)
| 토큰 | 값 |
|---|---|
| card (대시보드 카드 기본) | `0 4px 20px rgba(59,92,255,.08)` |
| sm | `0 2px 8px rgba(30,46,143,.06)` |
| md | `0 6px 16px rgba(30,46,143,.08)` |
| pop (모달·바텀시트) | `0 16px 40px rgba(30,46,143,.16)` |
| glow-blue (CTA 강조) | `0 6px 20px rgba(59,92,255,.35)` |
| glow-purple | `0 6px 20px rgba(140,82,255,.32)` |

## 모션 — "또로롱"(가볍게 통통)
| 토큰 | 값 |
|---|---|
| ease-standard | `Cubic(0.2, 0, 0.2, 1)` |
| ease-spring | `Cubic(0.34, 1.56, 0.64, 1)` |
| ease-out | `Cubic(0.16, 1, 0.3, 1)` |
| dur-fast | 120ms |
| dur-base | 200ms |
| dur-slow | 320ms |

## 레이아웃
- 앱 캔버스 폭: **420**
- 탭바 높이: **64**
- 헤더 높이: **56**

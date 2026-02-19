# ACE-Step 1.5 설치 및 사용 가이드

## 1. 개요

ACE-Step 1.5는 AI 기반 음악 생성 도구로, 텍스트 프롬프트를 입력하면 음악을 생성해주는 오픈소스 프로젝트이다.

- GitHub: https://github.com/ace-step/ACE-Step-1.5.git
- 모델: ACE-Step/Ace-Step1.5 (HuggingFace)
- 라이선스: MIT

---

## 2. 시스템 요구사항

| 항목 | 최소 | 권장 |
|------|------|------|
| Python | 3.11.x (필수) | 3.11.9 |
| GPU | NVIDIA 6GB VRAM | NVIDIA 12GB+ VRAM |
| CUDA | 12.8 | 12.8 |
| OS | Windows 10/11, Linux, macOS (Apple Silicon) | Windows 11 |
| RAM | 16GB | 32GB |

### GPU 티어별 제한사항

| 티어 | VRAM | LM 사용 | 최대 생성 길이 | 최대 배치 |
|------|------|---------|---------------|-----------|
| Tier3 | ~8GB | 0.6B만 가능 | LM 있음: 240초 (4분) / LM 없음: 360초 (6분) | LM 있음: 1 / LM 없음: 2 |
| Tier2 | ~12GB | 0.6B, 1.7B | 더 김 | 더 많음 |
| Tier1 | 16GB+ | 모두 가능 | 제한 완화 | 제한 완화 |

> 8GB GPU에서는 CPU Offload가 자동 활성화되며, LLM(언어모델)은 기본적으로 비활성화된다.

---

## 3. 설치 과정

### 3.1 Python 3.11 설치

ACE-Step은 Python 3.11만 지원한다 (`requires-python = "==3.11.*"`).

```bash
# Python 3.11이 이미 설치되어 있는지 확인
py -3.11 --version

# 설치되어 있지 않다면 공식 사이트에서 다운로드
# https://www.python.org/downloads/release/python-3119/
# 또는 커맨드라인으로 설치:
curl -L -o python311.exe "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
start //wait "" python311.exe /quiet InstallAllUsers=0 PrependPath=0 Include_launcher=1 Include_pip=1

# 설치 확인
py --list
# 출력 예: -V:3.11  Python 3.11 (64-bit)
```

### 3.2 프로젝트 클론

```bash
git clone https://github.com/ace-step/ACE-Step-1.5.git acestep
cd acestep
```

### 3.3 가상환경 생성 및 활성화

```bash
# 가상환경 생성
py -3.11 -m venv .venv

# 활성화 (Windows CMD)
.venv\Scripts\activate.bat

# 활성화 (PowerShell)
.venv\Scripts\Activate.ps1

# 활성화 (Git Bash / MSYS2)
source .venv/Scripts/activate

# Python 버전 확인
python --version
# 출력: Python 3.11.9
```

### 3.4 pip 업그레이드

```bash
python -m pip install --upgrade pip
```

### 3.5 의존성 설치

```bash
pip install -r requirements.txt
```

설치되는 주요 패키지:
- **torch 2.7.1+cu128**: PyTorch (CUDA 12.8)
- **flash-attn 2.8.2**: Flash Attention (Windows CUDA 빌드)
- **transformers 4.57.x**: HuggingFace Transformers
- **gradio 6.2.0**: Web UI 프레임워크
- **diffusers**: Diffusion 모델 라이브러리

### 3.6 nano-vllm 로컬 패키지 설치

```bash
pip install -e acestep/third_parts/nano-vllm
```

### 3.7 모델 다운로드

#### 메인 모델 (자동)

최초 서버 실행 시 HuggingFace에서 DiT 모델이 자동 다운로드된다.
- 다운로드 위치: `acestep/checkpoints/`
- 모델: `ACE-Step/Ace-Step1.5` (28개 파일)

#### LM 모델 (수동 - Simple 모드 사용 시 필요)

메인 모델에는 1.7B LM만 포함되어 있다. 8GB GPU에서는 1.7B가 너무 커서 KV cache 부족 에러가 발생하므로, **0.6B 모델을 별도로 다운로드**해야 한다.

```bash
# 가상환경 활성화 후
huggingface-cli download ACE-Step/acestep-5Hz-lm-0.6B --local-dir checkpoints/acestep-5Hz-lm-0.6B
```

> **참고**: Custom 모드만 사용할 예정이라면 LM 모델 다운로드는 불필요하다.

---

## 4. 서버 실행

### 4.1 기본 실행 (Custom 모드 전용, LLM 없음)

```bash
cd D:\Work_Dan\git\gitcjteams\acestep
.venv\Scripts\activate
python acestep\acestep_v15_pipeline.py --port 7860 --server-name 127.0.0.1 --language en --config_path acestep-v15-turbo --init_service true
```

### 4.2 LLM 포함 실행 (Simple 모드 사용 가능)

```bash
cd D:\Work_Dan\git\gitcjteams\acestep
.venv\Scripts\activate
python acestep\acestep_v15_pipeline.py --port 7860 --server-name 127.0.0.1 --language en --config_path acestep-v15-turbo --lm_model_path acestep-5Hz-lm-0.6B --init_llm true --init_service true
```

> **주의 (8GB GPU)**: LLM 활성화 시 GPU 메모리가 56% 점유되어 여유가 줄어든다. 최대 생성 길이가 360초 → 240초로 줄고, 배치 사이즈가 2 → 1로 제한된다.

### 4.3 LLM 모델 선택 가이드

| LM 모델 | 크기 | 8GB GPU | 12GB+ GPU |
|---------|------|---------|-----------|
| `acestep-5Hz-lm-0.6B` | 약 1.2GB | 사용 가능 (GPU 56% 점유) | 사용 가능 |
| `acestep-5Hz-lm-1.7B` | 약 3.4GB | 사용 불가 (KV cache 부족) | 사용 가능 |
| `acestep-5Hz-lm-4B` | 약 8GB | 사용 불가 | 16GB+ 권장 |

### 4.4 주요 실행 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `--port` | 서버 포트 | 7860 |
| `--server-name` | 서버 주소 (0.0.0.0이면 외부 접속 가능) | 127.0.0.1 |
| `--language` | UI 언어 (en, zh, ja) | en |
| `--config_path` | 모델 설정 (acestep-v15-turbo 또는 acestep-v15-base) | acestep-v15-turbo |
| `--lm_model_path` | LM 모델 경로 | acestep-5Hz-lm-0.6B |
| `--init_llm` | LLM 초기화 여부 (true/false/auto) | auto (8GB에서는 false) |
| `--init_service` | 시작 시 모델 자동 로드 | false |
| `--share` | Gradio 공유 링크 생성 | 없음 |

### 4.5 서버 상태 확인

```bash
# 브라우저에서 접속
http://127.0.0.1:7860

# 또는 커맨드라인으로 확인
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:7860/
# 200이면 정상 실행 중
```

### 4.6 서버 종료

서버를 실행한 터미널에서 `Ctrl+C`를 누른다.

---

## 5. 사용자 매뉴얼

### 5.1 Gradio UI 접속

브라우저에서 http://127.0.0.1:7860 접속한다.
"ACE-Step V1.5 Playground" 화면이 나타난다.

### 5.2 생성 모드

UI에는 **Simple 모드**와 **Custom 모드** 두 가지가 있다.

#### Simple 모드 (LLM 필수)

자연어로 설명하면 LLM이 태그, 가사, BPM, Duration 등을 자동 생성해준다.

**사전 조건**: 서버 실행 시 `--init_llm true` 옵션 필요. 0.6B LM 모델 다운로드 필요.

**사용 방법**:
1. **Simple/Custom** 라디오에서 **Simple** 선택 (기본값)
2. **"Describe your music"** 텍스트박스에 원하는 음악 설명 입력
3. **Instrumental** 체크 (연주곡인 경우)
4. **"Create Sample"** 클릭 → LLM이 태그/가사/BPM/Duration 자동 생성
5. **Optional Parameters** 열어서 **Duration을 직접 확인/수정** (중요!)
6. **"Generate Music"** 클릭

> **주의**: Simple 모드에서 LLM이 Duration을 자동으로 설정하는데, 긴 곡(150초 이상)으로 설정될 수 있다. 8GB GPU에서는 생성에 수 분~10분 이상 소요될 수 있으므로, **Duration을 60~90초로 수동 조정하는 것을 권장**한다.

> **LLM 미초기화 시**: "LM not initialized" 경고가 나오며 Simple 모드를 사용할 수 없다. Custom 모드를 사용해야 한다.

#### Custom 모드 (LLM 불필요, 권장)

LLM 없이 직접 태그와 가사를 입력한다. 8GB GPU 환경에서 가장 안정적인 방법이다.

**사용 방법**:
1. **Simple/Custom** 라디오에서 **Custom** 선택
2. **Music Caption**: 음악 스타일/장르 태그 입력
3. **Lyrics**: 가사 입력 (연주곡은 `[inst]`)
4. **Instrumental** 체크 (연주곡인 경우)
5. **Optional Parameters** → **Duration** 설정 (예: `60`)
6. **"Generate Music"** 클릭

### 5.3 입력 필드 설명

#### 필수 입력

| 필드 | 설명 | 예시 |
|------|------|------|
| **Music Caption** | 음악 스타일/장르 태그 (쉼표 구분) | `piano, instrumental, calm, bright, peaceful` |
| **Lyrics** | 가사. 연주곡은 `[inst]` 입력 | `[inst]` 또는 `[verse]\nHello world...` |
| **Instrumental** | 체크하면 가사 없는 연주곡 생성 | 체크/해제 |

#### 선택 입력 (Optional Parameters)

| 필드 | 설명 | 기본값 |
|------|------|--------|
| **Duration** | 생성 길이(초). -1이면 자동 | -1 |
| **BPM** | 템포 (비워두면 자동) | 없음 |
| **Key/Scale** | 조성 (예: C major, A minor) | 없음 |
| **Time Signature** | 박자 (4=4/4박자, 3=3/4박자) | 없음 |
| **Batch Size** | 한번에 생성할 개수 | 2 (LLM 활성화 시 1) |

> **Duration 설정 권장**: 8GB GPU에서는 60~90초 권장. Duration이 길수록 생성 시간이 비례하여 증가한다.

#### 고급 설정 (Advanced Settings)

| 필드 | 설명 | 기본값 |
|------|------|--------|
| **Inference Steps** | 추론 단계 수 (높을수록 품질 좋지만 느림) | 8 |
| **Shift** | 노이즈 스케줄 시프트 | 3.0 |
| **Seed** | 시드값. -1이면 랜덤 | -1 |
| **Audio Format** | 출력 포맷 (mp3, flac) | mp3 |

#### 기타 옵션

| 옵션 | 설명 |
|------|------|
| **Think** | LLM 사고 과정 활성화 (Simple 모드에서 메타데이터 자동 생성에 사용) |
| **AutoGen** | 생성 완료 후 자동으로 다음 배치 연속 생성 (여러 버전 비교 시 유용) |
| **CaptionRewrite** | LLM이 캡션을 자동 보강 |
| **LM Codes Hints** | 기존 오디오 코드 입력 (커버/트랜스크립션용, 일반 생성 시 비워둠) |

### 5.4 Task Type (작업 유형)

| 타입 | 설명 |
|------|------|
| **text2music** | 텍스트 → 음악 생성 (기본) |
| **audio_continuation** | 기존 오디오 이어서 생성 |
| **audio_repainting** | 기존 오디오 특정 구간 재생성 |

### 5.5 가사 포맷

```
[verse]
첫 번째 절 가사...

[chorus]
후렴 가사...

[bridge]
브릿지 가사...

[outro]
아웃트로 가사...
```

연주곡(instrumental)인 경우:
```
[inst]
```

### 5.6 출력

생성된 음악은 UI에서 바로 재생할 수 있으며, 파일은 다음 경로에 저장된다:
```
acestep/gradio_outputs/
```

---

## 6. 예제 프롬프트

### 밝고 차분한 피아노 연주 (1분)

- **Music Caption**: `piano, instrumental, calm, bright, peaceful, solo piano, relaxing`
- **Lyrics**: `[inst]`
- **Instrumental**: 체크
- **Duration**: `60`

### 어쿠스틱 기타 팝송

- **Music Caption**: `acoustic guitar, pop, warm, male vocal, folk, singer-songwriter`
- **Lyrics**:
  ```
  [verse]
  Walking down the road...
  [chorus]
  Singing in the rain...
  ```
- **Duration**: `120`

### 일렉트로닉 비트

- **Music Caption**: `electronic, EDM, energetic, synth, dance, bass, upbeat`
- **Lyrics**: `[inst]`
- **Instrumental**: 체크
- **Duration**: `90`

---

## 7. 트러블슈팅

| 문제 | 원인 | 해결 방법 |
|------|------|-----------|
| Python 3.11이 없다고 나옴 | Python 3.11 미설치 | `py --list`로 확인. 없으면 3.11 설치 필요 |
| CUDA out of memory | GPU 메모리 부족 | Duration 줄이기, Batch Size 1로 변경, Offload to CPU 활성화 |
| 모델 다운로드 실패 | 네트워크 문제 | HuggingFace 접속 가능한지 확인 |
| 서버가 안 뜸 | 포트 충돌 | `netstat -an \| findstr 7860`으로 확인 |
| flash-attn 오류 | 버전 불일치 | Python 3.11 + CUDA 12.8 조합만 지원 |
| torchao 경고 | 버전 비호환 | `Skipping import of cpp extensions` 경고는 무시 가능 |
| LM not initialized | LLM 미로드 | `--init_llm true` 옵션으로 서버 재시작, 또는 Custom 모드 사용 |
| Insufficient KV cache (1.7B LM) | 1.7B 모델이 8GB GPU에서 너무 큼 | 0.6B 모델 다운로드 후 `--lm_model_path acestep-5Hz-lm-0.6B` 사용 |
| 50%에서 멈춘 것처럼 보임 | LLM이 오디오 토큰 생성 중 | 에러가 아님. Duration이 길면 수 분~10분 소요. Duration을 60초로 줄이면 빨라짐 |
| Generate 후 진행이 매우 느림 | Duration이 너무 길게 설정됨 | Simple 모드에서 LLM이 Duration을 자동 설정함. Optional Parameters에서 60~90초로 수동 조정 |

### LLM 관련 상세 트러블슈팅

#### 8GB GPU에서 Simple 모드를 사용하려면

1. **0.6B LM 모델 다운로드** (필수):
   ```bash
   huggingface-cli download ACE-Step/acestep-5Hz-lm-0.6B --local-dir checkpoints/acestep-5Hz-lm-0.6B
   ```

2. **LLM 활성화하여 서버 시작**:
   ```bash
   python acestep\acestep_v15_pipeline.py --port 7860 --server-name 127.0.0.1 --language en --config_path acestep-v15-turbo --lm_model_path acestep-5Hz-lm-0.6B --init_llm true --init_service true
   ```

3. **Duration을 반드시 수동 확인**: Simple 모드에서 Create Sample 후, Optional Parameters의 Duration을 60~90초로 조정

#### 1.7B LM 모델 사용 시 "Insufficient KV cache" 에러

```
RuntimeError: Insufficient KV cache to schedule sequence.
Free blocks: 1/1, blocks needed: 2, prompt tokens: 257, block size: 256.
```

이 에러는 1.7B 모델이 8GB VRAM을 거의 전부 사용하여 KV cache에 공간이 없는 것이다.
해결: `--lm_model_path acestep-5Hz-lm-0.6B`로 변경 (0.6B 모델 사전 다운로드 필요)

---

## 8. 폴더 구조

```
acestep/
├── .venv/                  # Python 가상환경
├── acestep/                # 메인 소스코드
│   ├── acestep_v15_pipeline.py  # 엔트리포인트
│   ├── gradio_ui/          # Gradio UI 코드
│   ├── handler.py          # 모델 핸들러
│   ├── gpu_config.py       # GPU 설정
│   └── third_parts/        # nano-vllm 등 서드파티
├── checkpoints/            # 모델 파일
│   ├── acestep-v15-turbo/  # DiT 모델 (자동 다운로드)
│   ├── acestep-5Hz-lm-0.6B/  # 0.6B LM 모델 (수동 다운로드)
│   ├── acestep-5Hz-lm-1.7B/  # 1.7B LM 모델 (자동 다운로드)
│   ├── Qwen3-Embedding-0.6B/ # 임베딩 모델
│   └── vae/                # VAE 디코더
├── gradio_outputs/         # 생성된 음악 출력
├── cli.py                  # CLI 모드
├── requirements.txt        # Python 의존성
├── start_gradio_ui.bat     # Windows 실행 스크립트
└── start_gradio_ui.sh      # Linux/Mac 실행 스크립트
```

---

## 9. CLI 모드 (명령어로 직접 생성)

UI 없이 커맨드라인으로 바로 음악을 생성할 수도 있다.

```bash
cd D:\Work_Dan\git\gitcjteams\acestep
.venv\Scripts\activate

python cli.py \
  --tags "piano, instrumental, calm, bright, peaceful, solo piano" \
  --lyrics "[inst]" \
  --duration 60 \
  --config_path acestep-v15-turbo
```

---

## 10. 생성 속도 참고 (RTX 5060 8GB 기준)

| 항목 | LLM 없음 (Custom) | LLM 있음 (Simple, 0.6B) |
|------|-------------------|------------------------|
| 서버 시작 시간 | ~15초 | ~30초 (LM 로딩 ~18초) |
| 60초 음악 생성 | 빠름 | LM 토큰 생성 + DiT 생성 |
| 150초 음악 생성 | 보통 | 매우 느림 (수 분~10분) |
| 최대 Duration | 360초 | 240초 |
| 최대 Batch Size | 2 | 1 |
| GPU 메모리 사용 | ~2GB (DiT만) | ~5.7GB (DiT + LM) |

> **권장**: 8GB GPU에서는 **Custom 모드 + Duration 60~90초**가 가장 빠르고 안정적이다. Simple 모드는 LLM이 자동 설정하는 Duration이 길어질 수 있으므로 반드시 수동 조정 필요.

---

*작성일: 2026-02-10*
*환경: Windows 11, Python 3.11.9, NVIDIA RTX 5060 8GB, CUDA 12.8*

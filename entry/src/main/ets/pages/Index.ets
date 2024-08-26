import { AVPlayerDemo, avPlayer } from "./AVPlayer";
import { display } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State musicName: string = '青花瓷';
  @State artist: string = '周杰伦';
  @State playState: string = 'play';
  @State iconPath: string = 'play-fill.svg';
  @State player: AVPlayerDemo = avPlayer;
  private lastSliderChangeMode: number = 0;
  @State displayScreenWidth: number = 0;
  @State progressBarWidth: number = 0;

  onPageShow(): void {
    avPlayer.avPlayerLiveDemo('http://175.178.109.217:8080/data/test_music.mp3');
  }

  aboutToAppear() {
    // 获取屏幕的宽度
    display.getAllDisplays((err, data) => {
      let displayClass: display.Display | null = null;
      displayClass = display.getDefaultDisplaySync();
      this.displayScreenWidth = px2vp(displayClass.width);
    })
  }

  build() {
    RelativeContainer() {

      Column() {
        // 歌曲名字
        Row() {
          Text(this.musicName)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }

        // 歌手
        Row() {
          Text(this.artist)
            .fontSize(20)
            .fontWeight(FontWeight.Normal)
        }

        // 专辑图片
        Row() {
          Image('http://175.178.109.217:8080/data/test_image.webp')
            .width(200)
            .height(200)
        }

        Row() {
          Stack() {
            Progress({ value: 50, type: ProgressType.Linear })
              .color('#D9D9D9')
              .backgroundColor('#EBEBEB')
              .style({
                // 设置进度条宽度,ux设计上Slider的默认高度为4vp
                strokeWidth: 4,
                enableSmoothEffect: true
              })
              .width(this.progressBarWidth - 24)

            Slider({
              value: avPlayer.nowTime,
              min: 0,
              max: this.player.totalTime,
              style: SliderStyle.OutSet,
            })
              .showTips(true)
              .onChange((value: number, mode: SliderChangeMode) => {
                value = Math.round(value);
                // 点击进度条改变进度
                if (mode == 0) {
                  avPlayer.changeTime(value);
                }
                // 拖动进度条改变进度
                if (this.lastSliderChangeMode == 1 && mode == 2) {
                  avPlayer.changeTime(value);
                }
                this.lastSliderChangeMode = mode;
              })
          }.onAreaChange((oldValue: Area, newValue: Area) => {
            // 整个进度条由两个控件叠加，其中progress控件需要知道整个控件的宽度。
            this.progressBarWidth=newValue.width as number;
          })

          Text(this.player.nowTime.toFixed(0)).fontSize(12)

        }.id('progress-bar').width('80%').align(Alignment.Center).justifyContent(FlexAlign.Center)

        Row() {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Row() {
              Image($rawfile(this.iconPath)).width(80).height(80)
            }.alignItems(VerticalAlign.Center)
          }
          .borderRadius(50)
          .backgroundColor(0x654321)
          .width(100)
          .height(100)
          .onClick(() => {
            avPlayer.avPlayerPlayAndPause(this.playState);
            if (this.playState == 'pause') {
              this.playState = 'play';
              this.iconPath = 'play-fill.svg';
            } else if (this.playState == 'play') {
              this.playState = 'pause';
              this.iconPath = 'pause-fill.svg';
            }
          })
        }

        Row(){
          Button("aaa")
            .onClick(()=>{
              avPlayer.getTrack();
            })
        }
      }

    }
    .align(Alignment.Center)
    .height('100%')
    .width('100%')
  }
}
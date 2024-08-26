import media from '@ohos.multimedia.media';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';

@Observed
export class AVPlayerDemo {
  public totalTime: number = 0;
  public nowTime: number = 0;
  private isChangeProgress: boolean = false;
  private count: number = 0;
  private isSeek: boolean = true; // 用于区分模式是否支持seek操作
  private fileSize: number = -1;
  private fd: number = 0;
  private avPlayer: media.AVPlayer | null = null;

  // 注册avplayer回调函数
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
      this.isChangeProgress = false;
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })
    // 监听音频长度变化的情况
    avPlayer.on('durationUpdate', (time: number) => {
      this.totalTime = time;
    })
    // 监听当前音频播放的位置
    avPlayer.on('timeUpdate', (time: number) => {
      if (!this.isChangeProgress) {
        this.nowTime = time;
      }
    })
    //订阅音视频缓存更新事件，好像需要你主动拖动进度条之后才会去加载内容
    avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      console.log("@@@@@@@@@@@@ bufferingUpdate", infoType.toString(), value);
    })

    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          console.info('AVPlayer state idle called.');
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          console.info('AVPlayer state initialized called.');
          this.avPlayer?.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayer state prepared called.');
          break;
        case 'playing': // play成功调用后触发该状态机上报
          console.info('AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          console.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          console.info('AVPlayer state stopped called.');
          avPlayer.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  async initAVPlayer() {
    this.avPlayer = await media.createAVPlayer();
    await this.setAVPlayerCallback(this.avPlayer);
  }

  async changeTime(time: number) {
    this.isChangeProgress = true;
    this.nowTime = time;
    await this.avPlayer?.seek(time);
  }

  // 以下demo为通过url设置网络地址来实现播放直播码流的demo
  async avPlayerLiveDemo(musicUrl: string) {

    if (this.avPlayer) {
      this.avPlayer.url = musicUrl;
    }
  }

  async avPlayerPlayAndPause(playState: string) {
    if (playState == 'play') {
      await this.avPlayer?.play();
    } else if (playState == 'pause') {
      await this.avPlayer?.pause();
    }
  }

  getTrack(){
    // 通过回调方式获取音视频轨道信息
    this.avPlayer?.getTrackDescription((err,data:media.MediaDescription[])=>{
      console.log("@@@@@@@@@@@",data);
    })
  }
}


const avPlayer: AVPlayerDemo = new AVPlayerDemo();

export { avPlayer };

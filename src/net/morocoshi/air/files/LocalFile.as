package net.morocoshi.air.files
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * ローカルファイルの保存、読み込み
	 * 
	 * @author	tencho
	 */
	public class LocalFile
	{
		static private const MODE_BOOLEAN:String = "boolean";
		static private const MODE_BYTE:String = "byte";
		static private const MODE_BYTEARRAY:String = "bytearray";
		static private const MODE_DOUBLE:String = "double";
		static private const MODE_FLOAT:String = "float";
		static private const MODE_INT:String = "int";
		static private const MODE_MULTIBYTE:String = "multibyte";
		static private const MODE_OBJECT:String = "object";
		static private const MODE_SHORT:String = "short";
		static private const MODE_UNSIGNEDBYTE:String = "unsignedbyte";
		static private const MODE_UNSIGNEDINT:String = "unsignedint";
		static private const MODE_UNSIGNEDSHORT:String = "unsignedshort";
		static private const MODE_UTF:String = "utf";
		static private const MODE_UTFBYTES:String = "utfbytes";
		
		/**
		 * [取扱注意]
		 * trueにするとapplicationDirectoryにも書き込めるようにセキュリティエラーを無理やり回避します。
		 * applicationDirectory内に書き込んだ場合、AIRアプリの再インストールに失敗するので基本的にfalseにしておいてください。
		 */
		static public var ignoreSecurity:Boolean = false;
		/**
		 * [取扱注意]
		 * trueにするとデータ読み込み時の解凍処理をスキップします。
		 * 昔は圧縮設定がなかったので、古いデータを読み込む際に一度だけtrueにする必要があります。
		 */
		static public var ignoreUncompress:Boolean = false;
		
		/**
		 * 指定フォルダを生成します。（ignoreSecurity対応版）
		 * @param	file
		 * @return
		 */
		static public function createDirectory(file:File):Boolean
		{
			if (ignoreSecurity) file = new File(file.nativePath);
			try
			{
				file.createDirectory();
			}
			catch (e:Error)
			{
				return false;
			}
			return true;
		}
		
		/** AMFを書き込む */
		static public function writeObject(file:File, data:*, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_OBJECT, overwrite, useCompress, compress); }
		/** Booleanを書き込む */
		static public function writeBoolean(file:File, data:Boolean, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_BOOLEAN, overwrite, useCompress, compress); }
		/** 8bit整数（符号あり）を書き込む */
		static public function writeByte(file:File, data:int, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_BYTE, overwrite, useCompress, compress); }
		/** 16bit整数（符号あり）を書き込む */
		static public function writeShort(file:File, data:int, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_SHORT, overwrite, useCompress, compress); }
		/** 32bit整数（符号あり）を書き込む */
		static public function writeInt(file:File, data:int, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_INT, overwrite, useCompress, compress); }
		/** 32bit整数（符号なし）を書き込む */
		static public function writeUnsignedInt(file:File, data:uint, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_UNSIGNEDINT, overwrite, useCompress, compress); }
		/** 32bit浮動小数点数を書き込む */
		static public function writeFloat(file:File, data:Number, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_FLOAT, overwrite, useCompress, compress); }
		/** 64bit浮動小数点数を書き込む */
		static public function writeDouble(file:File, data:Number, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_DOUBLE, overwrite, useCompress, compress); }
		/** 文字コード指定で文字列を書き込む */
		static public function writeMultiByte(file:File, data:String, charSet:String, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_MULTIBYTE, overwrite, useCompress, compress, charSet); }
		/** UTF文字列を書き込む（先頭２バイトにバイト数が付加） */
		static public function writeUTF(file:File, data:String, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_UTF, overwrite, useCompress, compress); }
		/** UTF文字列を書き込む */
		static public function writeUTFBytes(file:File, data:String, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_UTFBYTES, overwrite, useCompress, compress); }
		/** ByteArrayを書き込む */
		static public function writeByteArray(file:File, data:ByteArray, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false):Boolean { return write(file, data, MODE_BYTEARRAY, overwrite, useCompress, compress); }
		
		/**
		 * ファイルにデータを書き込む。
		 * @param	file	書き込み先のファイル。
		 * @param	data	書き込むデータ。
		 * @param	mode	書き込むデータの種類。
		 * @param	overwrite	ファイルが存在したら上書きする。
		 * @param	useCompress	圧縮フラグを先頭に追加するか
		 * @param	compress	圧縮するか
		 * @param	option	追加引数
		 * @return
		 */
		static private function write(file:File, data:*, mode:String, overwrite:Boolean = true, useCompress:Boolean = false, compress:Boolean = false, option:* = null):Boolean
		{
			var success:Boolean = true;
			if (!overwrite && file.exists) return false;
			
			//セキュリティエラーを回避する
			if (ignoreSecurity)
			{
				file = new File(file.nativePath);
			}
			
			var fs:FileStream = new FileStream();
			try
			{
				fs.open(file, FileMode.WRITE);
				if (useCompress)
				{
					fs.writeBoolean(compress);
				}
				
				var output:IDataOutput = useCompress? new ByteArray() : fs;
				switch(mode)
				{
					case MODE_BOOLEAN		: output.writeBoolean(data); break;
					case MODE_BYTE			: output.writeByte(data); break;
					case MODE_DOUBLE		: output.writeDouble(data); break;
					case MODE_FLOAT			: output.writeFloat(data); break;
					case MODE_INT			: output.writeInt(data); break;
					case MODE_SHORT			: output.writeShort(data); break;
					case MODE_UNSIGNEDINT	: output.writeUnsignedInt(data); break;
					case MODE_MULTIBYTE		: output.writeMultiByte(data, option); break;
					case MODE_OBJECT		: output.writeObject(data); break;
					case MODE_UTF			: output.writeUTF(data); break;
					case MODE_UTFBYTES		: output.writeUTFBytes(data); break;
					case MODE_BYTEARRAY		: output.writeBytes(data, 0, file.size); break;
				}
				if (useCompress)
				{
					if (compress)
					{
						ByteArray(output).compress();
					}
					fs.writeBytes(output as ByteArray, 0, ByteArray(output).bytesAvailable);
				}
			}
			catch (e:Error)
			{
				success = false;
			}
			finally
			{
				fs.close();
			}
			return success;
		}
		
		/** [AMF]を読み込む */
		static public function readObject(file:File, useCompress:Boolean = false):* { return read(file, MODE_OBJECT, useCompress); }
		/** [Boolean]を読み込む */
		static public function readBoolean(file:File, useCompress:Boolean = false):Boolean { return read(file, MODE_BOOLEAN, useCompress); }
		/** [int]を読み込む */
		static public function readByte(file:File, useCompress:Boolean = false):int { return read(file, MODE_BYTE, useCompress); }
		/** [int]を読み込む */
		static public function readShort(file:File, useCompress:Boolean = false):int { return read(file, MODE_SHORT, useCompress); }
		/** [int]を読み込む */
		static public function readInt(file:File, useCompress:Boolean = false):int { return read(file, MODE_INT, useCompress); }
		/** [uint]を読み込む */
		static public function readUnsignedByte(file:File, useCompress:Boolean = false):uint { return read(file, MODE_UNSIGNEDBYTE, useCompress); }
		/** [uint]を読み込む */
		static public function readUnsignedShort(file:File, useCompress:Boolean = false):uint { return read(file, MODE_UNSIGNEDSHORT, useCompress); }
		/** [uint]を読み込む */
		static public function readUnsignedInt(file:File, useCompress:Boolean = false):uint { return read(file, MODE_UNSIGNEDINT, useCompress); }
		/** [Number]を読み込む */
		static public function readFloat(file:File, useCompress:Boolean = false):Number { return read(file, MODE_FLOAT, useCompress); }
		/** [Number]を読み込む */
		static public function readDouble(file:File, useCompress:Boolean = false):Number { return read(file, MODE_DOUBLE, useCompress); }
		/**
		 * 文字コード指定で[String]を読み込む
		 * @param	file
		 * @param	charSet	[shift-jis]
		 * @return
		 */
		static public function readMultiByte(file:File, charSet:String, useCompress:Boolean = false):String { return read(file, MODE_MULTIBYTE, useCompress, charSet); }
		/** [String]を読み込む */
		static public function readUTF(file:File, useCompress:Boolean = false):String { return read(file, MODE_UTF, useCompress); }
		/** [String]を読み込む */
		static public function readUTFBytes(file:File, useCompress:Boolean = false):String { return read(file, MODE_UTFBYTES, useCompress); }
		/** [XML]を読み込む */
		static public function readXML(file:File, useCompress:Boolean = false):XML
		{
			var result:String = read(file, MODE_UTFBYTES, useCompress);
			if (result === null) return null;
			return new XML(result);
		}
		
		/** [ByteArray]を読み込む */
		static public function readByteArray(file:File, useCompress:Boolean = false):ByteArray { return read(file, MODE_BYTEARRAY, useCompress); }
		
		static private var bitmapLoaderCache:Dictionary = new Dictionary();
		static private var bitmapCompleteCache:Dictionary = new Dictionary();
		static private var bitmapErrorCache:Dictionary = new Dictionary();
		
		static private function deleteLoaderCache(loader:Loader):void 
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bitmapCompleteCache[loader]);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, bitmapErrorCache[loader]);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, bitmapErrorCache[loader]);
			
			delete bitmapLoaderCache[loader];
			delete bitmapCompleteCache[loader];
			delete bitmapErrorCache[loader];
		}
		
		/**
		 * 画像を読み込んでBitmapDataに変換する。complete関数の引数は(file:File, image:BitmapData)
		 * @param	file
		 * @param	complete
		 */
		static public function readBitmapData(file:File, complete:Function):void 
		{
			var bitmap_completeHandler:Function = function(e:Event):void
			{
				var info:LoaderInfo = e.currentTarget as LoaderInfo;
				deleteLoaderCache(info.loader);
				var bmp:Bitmap = info.content as Bitmap;
				complete(file, bmp? bmp.bitmapData : null);
			};
			var bitmap_errorHandler:Function = function(e:Event):void
			{
				var info:LoaderInfo = e.currentTarget as LoaderInfo;
				deleteLoaderCache(info.loader);
				complete(file, null);
			};
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bitmap_completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, bitmap_errorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, bitmap_errorHandler);
			
			bitmapLoaderCache[loader] = true;
			bitmapCompleteCache[loader] = bitmap_completeHandler;
			bitmapErrorCache[loader] = bitmap_errorHandler;
			
			loader.loadBytes(readByteArray(file));
		}
		
		static public function readBitmapDataList(files:Vector.<File>, complete:Function):void 
		{
			var stock:Vector.<File> = files.concat();
			var resultFiles:Vector.<File> = new Vector.<File>;
			var resultImages:Vector.<BitmapData> = new Vector.<BitmapData>;
			var loadNext:Function = function():void
			{
				if (stock.length == 0)
				{
					complete(resultFiles, resultImages);
					return;
				}
				var file:File = stock.shift();
				readBitmapData(file, function(f:File, image:BitmapData):void
				{
					resultFiles.push(f);
					resultImages.push(image);
					loadNext();
				});
			}
			loadNext();
		}
		
		/**
		 * [ByteArray]を非同期で読み込む
		 * @param	file
		 * @param	complete
		 * @return
		 */
		static private function readByteArrayAsync(file:File, complete:Function):ByteArray
		{
			var result:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			fs.addEventListener(Event.COMPLETE, stream_completeHandler);
			try
			{
				fs.openAsync(file, FileMode.READ);
				fs.position = 0;
				fs.readBytes(result, 0, file.size);
			}
			catch (e:Error)
			{
				fs.removeEventListener(Event.COMPLETE, stream_completeHandler);
				fs.close();
				result = null;
				complete(result);
			}
			
			function stream_completeHandler(e:Event):void 
			{
				var fs:FileStream = e.currentTarget as FileStream;
				fs.removeEventListener(Event.COMPLETE, arguments.callee);
				fs.close();
				complete(result);
			}
			
			return result;
		}
		
		static private function read(file:File, mode:String, useCompress:Boolean, ...rest):*
		{
			var result:*;
			
			if (!file.exists)
			{
				return null;
			}
			
			var fs:FileStream = new FileStream();
			try
			{
				fs.open(file, FileMode.READ);
				fs.position = 0;
				var uncompress:Boolean = useCompress? fs.readBoolean() : false;
				var input:IDataInput = useCompress? new ByteArray() : fs;
				
				if (useCompress)
				{
					fs.readBytes(ByteArray(input), 0, fs.bytesAvailable);
					if (uncompress)
					{
						ByteArray(input).uncompress();
					}					
				}
				
				switch(mode)
				{
					case MODE_BOOLEAN		: result = input.readBoolean(); break;
					case MODE_BYTE			: result = input.readByte(); break;
					case MODE_DOUBLE		: result = input.readDouble(); break;
					case MODE_FLOAT			: result = input.readFloat(); break;
					case MODE_INT			: result = input.readInt(); break;
					case MODE_SHORT			: result = input.readShort(); break;
					case MODE_UNSIGNEDBYTE	: result = input.readUnsignedByte(); break;
					case MODE_UNSIGNEDINT	: result = input.readUnsignedInt(); break;
					case MODE_UNSIGNEDSHORT	: result = input.readUnsignedShort(); break;
					case MODE_MULTIBYTE		: result = input.readMultiByte(input.bytesAvailable, rest[0]); break;
					case MODE_OBJECT		: result = input.readObject(); break;
					case MODE_UTF			: result = input.readUTF(); break;
					case MODE_UTFBYTES		: result = input.readUTFBytes(input.bytesAvailable); break;
					case MODE_BYTEARRAY		:
						if (useCompress)
						{
							result = input;
						}
						else
						{
							result = new ByteArray();
							input.readBytes(result, 0, 0);
							
						}
						break;
				}
			}
			catch (e:Error)
			{
				result = null;
			}
			finally
			{
				fs.close();
			}
			return result;
		}
		
	}
	
}
package net.morocoshi.air.files
{
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import mx.utils.StringUtil;
	
	/**
	 * File系処理
	 * 
	 * @author	tencho
	 */
	public class FileUtil
	{
		
		/**
		 * 指定パスにファイルが存在しているかどうかをチェックする
		 * @param	path
		 * @return
		 */
		static public function exists(path:String):Boolean
		{
			try
			{
				return new File(path).exists;
			}
			catch (e:Error) {}
			return false;
		}
		
		/**
		 * 指定Fileクラス（ファイルorフォルダ）が含んでいる全フォルダをリストアップ。
		 * @param	target
		 * @param	subdir	サブディレクトリを何層まで再起チェックするか。0でサブディレクトリ内チェック無し。
		 * @return
		 */
		public static function scanDirectory(target:File, addRoot:Boolean, subdir:Number = Infinity):Vector.<File>
		{
			var list:Vector.<File> = new Vector.<File>();
			if (target.isDirectory)
			{
				if (addRoot) list.push(target);
				if (subdir >= 0)
				{
					for each(var file:File in target.getDirectoryListing())
					{
						var glist:Vector.<File> = scanDirectory(file, true, subdir - 1);
						list = list.concat(glist);
					}
				}
			}
			return list;
		}
		
		/**
		 * 指定Fileクラス（ファイルorフォルダ）が含んでいる全ファイルをリストアップ
		 * @param	target
		 * @param	subdir	サブディレクトリを何層まで再起チェックするか。0でサブディレクトリ内チェック無し。
		 * @return
		 */
		public static function scanFile(target:File, subdir:Number = Infinity):Vector.<File>
		{
			var list:Vector.<File> = new Vector.<File>();
			if (target.isDirectory)
			{
				if (subdir >= 0)
				{
					for each(var file:File in target.getDirectoryListing())
					{
						var glist:Vector.<File> = scanFile(file, subdir - 1);
						list = list.concat(glist);
					}
				}
			}
			else
			{
				list.push(target);
			}
			return list;
		}
		
		static public function scanDirectoryAsync(root:File, addRoot:Boolean, complete:Function):void 
		{
			scanFileAsync(root, addRoot, completeScanFile);
			function completeScanFile(list:Vector.<File>):void
			{
				var folders:Vector.<File> = new Vector.<File>;
				for (var i:int = 0; i < list.length; i++) 
				{
					var file:File = list[i];
					if (file.isDirectory) folders.push(file);
				}
				complete(folders);
			}
		}
		
		static public function scanFileAsync(root:File, addRoot:Boolean, complete:Function):void 
		{
			var count:int = 0;
			var list:Vector.<File> = new Vector.<File>;
			if (addRoot) list.push(root);
			getFileListAsync(root);
			
			function getFileListAsync(file:File):void
			{
				count++;
				file.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingHandler);
				file.getDirectoryListingAsync();
			}
			
			function directoryListingHandler(e:FileListEvent):void
			{
				count--;
				File(e.currentTarget).removeEventListener(FileListEvent.DIRECTORY_LISTING, arguments.callee);
				for each(var file:File in e.files)
				{
					list.push(file);
					if (file.isDirectory) getFileListAsync(file);
				}
				if (!count)
				{
					complete(list);
				}
			}
		}
		
		public static function scanFileList(files:Vector.<File>, subdir:Number = Infinity):Vector.<File>
		{
			var list:Vector.<File> = new Vector.<File>();
			for each(var file:File in files)
			{
				list = list.concat(scanFile(file, subdir));
			}
			return list;
		}
		
		/**
		 * ファイルパスの￥を/に変えて、必要ならディレクトリパスで省略された/を付ける
		 * @param	path	パス文字列
		 * @param	addSlash	パスがフォルダなら、パスの最後に/をつける
		 * @return
		 */
		static public function correctPath(path:String, addSlash:Boolean = true):String
		{
			path = path.split('\\').join('/');
			var last:String = path.charAt(path.length - 1);
			if (addSlash)
			{
				//フォルダパスの最後が「/」でなかったら追加
				var f:File = FileUtil.toFile(path);
				if (f && f.isDirectory && last != '/') path += '/';
			}
			else 
			{
				//パスの最後が「/」だったら消す
				if (last == "/")
				{
					path = path.substr(0, path.length - 1);
				}
			}
			return path;
		}
		
		/**
		 * パス文字列から拡張子を抜いたファイル名部分だけ抜き出す。
		 * @param	name
		 * @return
		 */
		static public function getFileID(path:String):String 
		{
			path = getFileName(path);
			var list:Array = path.split('.');
			if (list.length == 1) return path;
			list.pop();
			return list.join('.');
		}
		
		/**
		 * ディレクトリ内のファイルの連番で最も大きい数字を取得する
		 * @param	dir
		 * @param	id
		 * @return
		 */
		static public function getUpperNumber(dir:File, id:String):int
		{
			return getUpperNumberByFileList(scanFile(dir, 0), id);
		}
		
		/**
		 * ディレクトリ内のファイルの連番で最も大きい数字を取得する
		 * @param	list
		 * @param	id
		 * @return
		 */
		static public function getUpperNumberByFileList(list:Vector.<File>, id:String):int
		{
			var max:int = -1;
			for each (var f:File in list) 
			{
				if (f.name.indexOf(id) != 0) continue;
				var numID:String = getFileID(f.name).substr(id.length);
				var num:int = parseInt(numID);
				if (max < num) max = num;
			}
			return max;
		}
		
		/**
		 * パス文字列から拡張子付きファイル名を抜き出す
		 * @param	path
		 * @return
		 */
		static public function getFileName(path:String):String
		{
			path = correctPath(path);
			if (path.indexOf('/') != -1)
			{
				path = path.split('/').pop();
			}
			if (path.indexOf('?') != -1)
			{
				path = path.split('?')[0];
			}
			return path;
		}
		
		/**
		 * Fileオブジェクトをパス指定で作成。作成できなかったらnullが返る。
		 * @param	path
		 */
		static public function toFile(path:String):File 
		{
			if (path == null) return null;
			
			try
			{
				return new File(path);
			}
			catch (e:Error)
			{
			}
			return null;
		}
		
		/**
		 * 指定Fileディレクトリを生成して、成功したらtrueを返す。既に存在していたらfalseが返る。
		 * @param	f
		 * @return
		 */
		static public function createDirectory(f:File):Boolean
		{
			try
			{
				f.createDirectory();
			}
			catch (e:Error)
			{
				return false;
			}
			if (!f.exists)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * パス文字列からフォルダパス部分を抜き出す
		 * @param	path
		 */
		static public function getDirectory(path:String):String 
		{
			return path.substr(0, path.length - getFileName(path).length);
		}
		
		/**
		 * 指定フォルダ内に生成する「名前＋日付＋被らない番号」のファイル名を取得する
		 * @param	directory
		 * @param	name
		 * @return
		 */
		static public function getNumberingName(directory:File, name:String):String 
		{
			var date:Date = new Date();
			var yy:String = String(date.fullYear).substr(2);
			var m:String = String(date.month + 1);
			var d:String = String(date.date);
			var mm:String = "00".substr(m.length) + m;
			var dd:String = "00".substr(d.length) + d;
			var id:String = name + "_" + yy + mm + dd + "_";
			var index:int = FileUtil.getUpperNumber(directory, id) + 1;
			return id + String(index);
		}
		
		/**
		 * 指定フォルダ内に生成する「名前＋日付＋被らない番号」のファイル名を取得する
		 * @param	list
		 * @param	name
		 * @return
		 */
		static public function getNumberingNameByFileList(list:Vector.<File>, name:String):String
		{
			var date:Date = new Date();
			var yy:String = String(date.fullYear).substr(2);
			var m:String = String(date.month + 1);
			var d:String = String(date.date);
			var mm:String = "00".substr(m.length) + m;
			var dd:String = "00".substr(d.length) + d;
			var id:String = name + "_" + yy + mm + dd + "_";
			var index:int = FileUtil.getUpperNumberByFileList(list, id) + 1;
			return id + String(index);
		}
		
		/**
		 * ファイルをリネームしてリネーム後の新しいFileオブジェクトを返す。
		 * @param	file
		 * @param	newName
		 * @return
		 */
		static public function rename(file:File, newName:String):File
		{
			if (!newName || newName.search(/\r|\n|\\|\//) != -1) return null;
			try
			{
				var to:File = file.parent.resolvePath(newName);
				file.moveTo(to, false);
			}
			catch (e:Error)
			{
				return null;
			}
			return to;
		}
		
		/**
		 * OS別にFileオブジェクトの正しいパスを返す
		 * @param	file
		 * @return
		 */
		static public function url(file:File):String 
		{
			var osx:Boolean = (Capabilities.os.substr(0, 10) == "Mac OS 10.");
			var path:String = osx? file.url : file.nativePath;
			return path;
		}
		
		/**
		 * 
		 * @param	path
		 * @param	base
		 * @return
		 */
		static public function getRelativePath(path:String, base:String):String 
		{
			var paths:Array = correctPath(path, false).split("/");
			var bases:Array = correctPath(base, false).split("/");
			var i:int = 0;
			while (i < paths.length && i < bases.length && paths[i] == bases[i])
			{
				i++;
			}
			return StringUtil.repeat("../", bases.length - i) + paths.slice(i).join("/");
		}
		
		static public function getExtension(path:String, lowerCase:Boolean = true):String 
		{
			var file:String = path.split("\\").join("/").split("/").pop();
			if (file.indexOf(".") == -1)
			{
				return "";
			}
			
			var result:String = file.split(".").pop();
			if (lowerCase)
			{
				result = result.toLowerCase();
			}
			
			return result;
		}
		
		static public function changeExtension(file:File, ext:String):File 
		{
			return file.parent.resolvePath(FileUtil.getFileID(file.name) + "." + ext);
		}
		
		/**
		 * ファイル名に使えない文字が含まれているかチェックし、問題なければtrueが返る。
		 * @param	name
		 * @return
		 */
		static public function checkFileNameError(name:String):Boolean 
		{
			for each(var s:String in ["\\", "/", ":", "*", "?", '"', "<", ">", "|"])
			{
				if (name.indexOf(s) != -1) return false;
			}
			
			return true;
		}
		
		/**
		 * ファイル名に使えない文字を別の文字に置き換えた新しいファイル名を返す
		 * @param	name
		 * @param	replace
		 * @return
		 */
		static public function getFixedFileName(name:String, replace:String):String 
		{
			for each(var s:String in ["\\", "/", ":", "*", "?", '"', "<", ">", "|"])
			{
				if (name.indexOf(s) != -1)
				{
					name = name.split(s).join(replace);
				}
			}
			
			return name;
		}
		
	}
	
}
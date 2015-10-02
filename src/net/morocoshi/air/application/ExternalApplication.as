package net.morocoshi.air.application 
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author tencho
	 */
	public class ExternalApplication 
	{
		
		public function ExternalApplication() 
		{
			
		}
		
		/**
		 * 外部ファイルを起動する
		 * @param	file
		 * @param	args
		 * @param	closeInput
		 * @return
		 */
		static public function run(file:File, args:Array = null, closeInput:Boolean = true, workingDirectory:File = null):NativeProcess
		{
			if (NativeProcess.isSupported == false)
			{
				return null;
			}
			
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = file;
			info.workingDirectory = workingDirectory;
			info.arguments = new Vector.<String>;
			if (args)
			{
				var n:int = args.length;
				for (var i:int = 0; i < n; i++) 
				{
					info.arguments.push(args[i]);
				}
			}
			var process:NativeProcess = new NativeProcess();
			process.start(info);
			
			if (closeInput)
			{
				process.closeInput();
			}
			
			return process;
		}
		
	}

}
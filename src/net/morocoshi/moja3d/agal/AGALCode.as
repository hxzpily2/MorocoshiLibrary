package net.morocoshi.moja3d.agal 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AGALCode 
	{
		public var usedVarying:Object;
		public var programType:String;
		
		public var constantList:Vector.<AGALConstant>;
		public var codeLines:Vector.<String>;
		public var textureList:Vector.<AGALTexture>;
		public var constantIndexLink:Object;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	programType	頂点シェーダかフラグメントシェーダか？Context3DProgramType参照
		 */
		public function AGALCode(programType:String) 
		{
			usedVarying = { };
			this.programType = programType;
			constantList = new Vector.<AGALConstant>;
			codeLines = new Vector.<String>;
			textureList = new Vector.<AGALTexture>;
			constantIndexLink = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  リセット
		//
		//--------------------------------------------------------------------------
		
		public function clearAll():void
		{
			usedVarying = { };
			textureList.length = 0;
			constantList.length = 0;
			codeLines.length = 0;
			constantIndexLink = { };
		}
		
		public function clearTexture():void
		{
			textureList.length = 0;
		}
		
		public function clearConstant():void
		{
			constantList.length = 0;
		}
		
		public function clearCode():void 
		{
			usedVarying = { };
			codeLines.length = 0;
			constantIndexLink = { };
		}
		
		//--------------------------------------------------------------------------
		//
		//  定数の追加
		//
		//--------------------------------------------------------------------------
		/**
		 * 定数をMatrix3Dで追加する（4つ分消費）
		 * @param	id
		 * @param	matrix
		 * @param	transposed
		 * @return
		 */
		public function addConstantsFromMatrix(id:String, matrix:Matrix3D, transposed:Boolean):AGALConstant
		{
			var constant:AGALConstant = new AGALConstant();
			constant.initMatrix(id, matrix, transposed);
			constantList.push(constant);
			return constant;
		}
		
		/**
		 * 定数をMatrix3Dで追加する（4つ分消費）（配列版）
		 * @param	id
		 * @param	matrix
		 * @param	transposed
		 * @return
		 */
		public function addConstantListFromMatrix(id:String, matrix:Matrix3D, transposed:Boolean):AGALConstant 
		{
			var constant:AGALConstant = new AGALConstant();
			constant.listMode = true;
			constant.initMatrix(id, matrix, transposed);
			constantList.push(constant);
			return constant;
		}
		
		/**
		 * 定数をVectorで追加する
		 * @param	id
		 * @param	vector
		 * @return
		 */
		public function addConstantsFromVector(id:String, vector:Vector.<Number> = null):AGALConstant
		{
			if (vector == null)
			{
				vector = new Vector.<Number>(4, true);
			}
			
			var constant:AGALConstant = new AGALConstant();
			constant.initVector(id, vector);
			constantList.push(constant);
			return constant;
		}
		
		/**
		 * 定数をArrayで追加する
		 * @param	id	最初はアットマークで始める
		 * @param	array
		 * @return
		 */
		public function addConstantsFromArray(id:String, array:Array = null):AGALConstant
		{
			if (array == null)
			{
				array = [0, 0, 0, 0];
			}
			
			var constant:AGALConstant = new AGALConstant();
			constant.initVector(id, new Vector.<Number>(4, true));
			constant.setVector.apply(null, array);
			constantList.push(constant);
			return constant;
		}
		
		/**
		 * 定数をVector3Dで追加する
		 * @param	id
		 * @param	vector3D
		 * @return
		 */
		public function addConstantsFromVector3D(id:String, vector3D:Vector3D):AGALConstant 
		{
			var constant:AGALConstant = new AGALConstant();
			var vector:Vector.<Number> = vector3D? new <Number>[vector3D.x, vector3D.y, vector3D.z, vector3D.w] : new <Number>[0,0,0,1];
			constant.initVector(id, vector);
			constantList.push(constant);
			return constant;
		}
		
		/**
		 * 定数をRGBとAlphaで追加する
		 * @param	id
		 * @param	rgb
		 * @param	alpha
		 * @return
		 */
		public function addConstantsFromColor(id:String, rgb:uint, alpha:Number):AGALConstant 
		{
			var constant:AGALConstant = new AGALConstant();
			constant.initVector(id, new Vector.<Number>());
			constant.setRGBA(rgb, alpha);
			constantList.push(constant);
			return constant;
		}
		
		//--------------------------------------------------------------------------
		//
		//  定数の転送
		//
		//--------------------------------------------------------------------------
		
		public function applyProgramConstants(context3D:Context3D, start:int):int 
		{
			var n:int = constantList.length;
			var index:int = start;
			for (var i:int = 0; i < n; i++) 
			{
				var constant:AGALConstant = constantList[i];
				if (!constant.enabled) continue;
				
				switch(constant.type)
				{
					case AGALConstant.VECTOR	:
						context3D.setProgramConstantsFromVector(programType, index, constant.vector);
						index += 1;
						break;
					case AGALConstant.MATRIX	:
						context3D.setProgramConstantsFromMatrix(programType, index, constant.matrix, constant.transposed);
						index += 4;
						break;
					//case AGALConstant.BYTEARRAY	: context3D.setProgramConstantsFromByteArray(programType, 0, constant.bytes); break;
				}
			}
			return index;
		}
		
		//--------------------------------------------------------------------------
		//
		//  シェーダーコードの追加
		//
		//--------------------------------------------------------------------------
		
		public function addCode(...args):void
		{
			var n:int = args.length;
			for (var i:int = 0; i < n; i++) 
			{
				var code:String = args[i];
				//#xxxxxが含まれる場合は使用したvarying名を記憶しておく
				if (code.indexOf("#") >= 0)
				{
					var match:Array = code.match(/#\w*/g);
					for (var j:int = 0; j < match.length; j++) 
					{
						var key:String = match[j];
						usedVarying[key] = true;
					}
				}
				if (code)
				{
					codeLines.push(code);
				}
			}
		}
		
		/**
		 * 
		 * @param	xml
		 */
		public function addXMLCode(xml:XML):void 
		{
			var args:Array = String(xml).split("\t").join("").split("\r\n").join("\n").split("\r").join("\n").split("\n");
			addCode.apply(null, args);
		}
		
		//--------------------------------------------------------------------------
		//
		//  シェーダーコードの連結
		//
		//--------------------------------------------------------------------------
		
		public function attachCode(code:AGALCode):void
		{
			var i:int;
			var n:int;
			n = code.codeLines.length;
			for (var key:String in code.usedVarying) 
			{
				usedVarying[key] = true;
			}
			for (i = 0; i < n; i++) 
			{
				codeLines.push(code.codeLines[i]);
			}
			//一時レジスタを破棄するためのコードを追加
			codeLines.push(DISPOSE_REGISTER);
		}
		
		/**
		 * 指定のAGALCodeからconstantとtextureをアタッチする
		 * @param	code
		 */
		public function attachConstant(code:AGALCode):void 
		{
			var i:int;
			var n:int;
			n = code.constantList.length;
			for (i = 0; i < n; i++) 
			{
				constantList.push(code.constantList[i]);
			}
			n = code.textureList.length;
			for (i = 0; i < n; i++) 
			{
				textureList.push(code.textureList[i]);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  シェーダプログラムコードの取得
		//
		//--------------------------------------------------------------------------
		
		public var varyingKey:Object = { };
		static public const DISPOSE_REGISTER:String = "dispose register";
		
		/**
		 * Program3Dを生成するためのAGALコードを生成します
		 * @param	common
		 * @param	varyingMap
		 * @param	usedVarying
		 * @return
		 */
		public function getCode(common:AGALCode, info:AGALInfo, varyingMap:Object, usedVarying:Object):String
		{
			varyingKey = { };
			
			var i:int;
			var n:int;
			
			var vf:String = (programType == Context3DProgramType.VERTEX)? "v" : "f";
			var globalCount:int = 0;
			var varyingCount:int = 0;
			
			var opecode:Object = { };
			opecode["+"] = "add";
			opecode["-"] = "sub";
			opecode["*"] = "mul";
			opecode["/"] = "div";
			var globalVariable:Object = { };
			var line:String;
			
			//コードセクション初期化
			var currentSectionIndex:int = 0;
			var sectionCode:Vector.<String> = new Vector.<String>;
			sectionCode[0] = "";
			
			//定数に変換する数値
			var constNumber:Object = {
				"0"		:"x",//-1は不要？
				"0.5"	:"y",
				"1"		:"z",
				"2"		:"w"
			};
			
			n = codeLines.length;
			for (i = 0; i < n; i++) 
			{
				line = codeLines[i];
				
				//vertexシェーダー内での#～の行でフラグメントで使われていないものを行ごと消す
				if (programType == Context3DProgramType.VERTEX && line.charAt(0) == "#")
				{
					var vrkey:String = line.match(/#\w+/)[0];
					if (!usedVarying[vrkey])
					{
						continue;
					}
				}
				
				//@0.5_1などを@number.xyに変える
				var numberConst:Array = line.match(/@([0-9.\-_]+)/);
				if (numberConst)
				{
					var numKey:String = "@number.";
					var nums:Array = numberConst[1].split("_");
					for (var j:int = 0; j < nums.length; j++) 
					{
						numKey += constNumber[nums[j]];
					}
					line = line.split(numberConst[0]).join(numKey);
					codeLines[i] = line;
				}
				/*
				line = line.split(".rgba").join(".xyzw");
				line = line.split(".rgb").join(".xyz");
				line = line.split(".r").join(".x");
				line = line.split(".g").join(".y");
				line = line.split(".b").join(".z");
				line = line.split(".a").join(".w");
				*/
				//#から始まるvaryingレジスタをv0～に変換する準備
				if (line.charAt(0) == "#")
				{
					var match:Array = line.match(/#\w+/);
					if (match)
					{
						var vkey:String = match[0];
						if (!varyingKey[vkey])
						{
							varyingKey[vkey] = "v" + varyingCount;
							varyingCount++;
						}
					}
				}
				
				//globalから始まるコードをvt～、ft～に変換する準備
				if (line.substr(0, 6) == "global")
				{
					var globalName:String = line.substr(7);
					if (!globalVariable[globalName])
					{
						globalVariable[globalName] = vf + "t" + globalCount;
						globalCount++;
					}
					continue;
				}
				
				if (line.substr(0, 3) == "var")
				{
					continue;
				}
				
				if (line == DISPOSE_REGISTER)
				{
					currentSectionIndex++;
					sectionCode[currentSectionIndex] = "";
					continue;
				}
				
				//[a = xxx(b)]を変換
				var match0:Array = line.match(/([^ ]*)\s*=\s*([a-z0-9]{3,3})\s*\((.*)\)/);
				if (match0) line = match0[2] + " " + match0[1] + ", " + match0[3];
				
				//[a += b]を変換
				var match1:Array = line.match(/([^ ]*)\s*(\+|\-|\*|\/)=\s*([^ ]*)/);
				if (match1) line = opecode[match1[2]] + " " + match1[1] + ", " + match1[1] + ", " + match1[3];
				
				//[a = b + c]を変換
				var match2:Array = line.match(/([^ ]*)\s*\=\s*([^ ]*)\s*(\+|\-|\*|\/)\s*([^ ]*)/);
				if (match2) line = opecode[match2[3]] + " " + match2[1] + ", " + match2[2] + ", " + match2[4];
				
				//[a = b]をmovに変換
				var eq:Array = line.match(/^([^ ]*)\s*\=\s*([^ ]*)\s*$/m);
				if (eq) line = "mov " + eq[1] + ", " + eq[2];
				
				sectionCode[currentSectionIndex] += line + "\n";
			}
			
			//一時レジスタ収集
			var varCount:int = globalCount;
			var sectionVariable:Vector.<Object> = new Vector.<Object>;
			var sectionVariableIndex:int = 0;
			var currentVariable:Object = sectionVariable[0] = { };
			for (i = 0; i < n; i++) 
			{
				line = codeLines[i];
				
				//varから始まるコードをvt～、ft～に変換する準備
				if (line.substr(0, 3) == "var")
				{
					var varName:String = line.substr(4);
					if (!currentVariable[varName])
					{
						currentVariable[varName] = vf + "t" + varCount;
						varCount++;
					}
					continue;
				}
				
				if (line == DISPOSE_REGISTER)
				{
					sectionVariableIndex++;
					currentVariable = sectionVariable[sectionVariableIndex] = { };
					varCount = globalCount;
				}
			}
			
			//レジスタの置換
			var index:int = 0;
			var from:String;
			var to:String;
			
			//最終的なAGALコード
			var data:String = "";
			
			//$xxxxxをft0～、vt0～に変換する
			n = sectionCode.length;
			for (i = 0; i < n; i++) 
			{
				var localVariable:Object = sectionVariable[i];
				for (key in localVariable)
				{
					sectionCode[i] = mapRegister(sectionCode[i], key, localVariable[key]);
				}
				data += sectionCode[i];
			}
			for (key in globalVariable)
			{
				data = mapRegister(data, key, globalVariable[key]);
			}
			
			//定数をvc～fc～に変換
			var constants:Vector.<AGALConstant> = common.constantList.concat(constantList);
			n = constants.length;
			for (i = 0; i < n; i++) 
			{
				if (constants[i].enabled == false) continue;
				
				//matrixはlengthが4
				var numConstants:int = constants[i].length;
				for (var k:int = 0; k < numConstants; k++) 
				{
					if (index >= info.constantsLimit[programType])
					{
						throw new Error("定数レジスタの数が" + info.constantsLimit[programType] + "を超えています！(" + getTotalConstantsNum(constants) + ")");
					}
					var constantIndex:String = (k == 0)? "" : "_" + String(k + 1);
					from = constants[i].id + constantIndex;
					to = vf + "c" + index;
					constantIndexLink[from] = index;
					data = mapRegister(data, from, to);
					index++;
				}
			}
			
			//textureのキーを変換
			var textureCount:int = -1;
			var agalTexture:AGALTexture;
			
			n = common.textureList.length;
			for (i = 0; i < n; i++) 
			{
				agalTexture = common.textureList[i];
				if (agalTexture.enabled == false) continue;
				
				textureCount++;
				from = agalTexture.id;
				to = "fs" + textureCount;
				if (data.indexOf(from + ",") >= 0)
				{
					throw new Error(from + "の直後に「,」を置くとAGALシンタックスエラーになります。");
				}
				data = data.split(from + " ").join(to + " ");
				data = data.split(from + "<").join(to + "<");
			}
			
			n = textureList.length;
			for (i = 0; i < n; i++) 
			{
				agalTexture = textureList[i];
				if (agalTexture.enabled == false) continue;
				
				textureCount++;
				from = agalTexture.id;
				to = "fs" + textureCount;
				if (data.indexOf(from + ",") >= 0)
				{
					throw new Error(from + "の直後に「,」を置くとAGALシンタックスエラーになります。");
				}
				data = data.split(from + " ").join(to + " ");
				data = data.split(from + "<").join(to + "<");
			}
			
			//#xxxxxをv0～に変換する
			var key:String;
			if (programType == Context3DProgramType.VERTEX)
			{
				varyingMap = varyingKey;
			}
			if (varyingMap)
			{
				for (key in varyingMap)
				{
					data = data.split(key).join(varyingMap[key]);
				}
			}
			
			data = data.substr(0, data.length - 1);
			return data;
		}
		
		private function getTotalConstantsNum(constants:Vector.<AGALConstant>):int
		{
			var count:int = 0;
			var n:int = constants.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (constants[i].enabled == false) continue;
				count += constants[i].length;
			}
			return count;
		}
		
		private function mapRegister(data:String, from:String, to:String):String 
		{
			data = data.split(from + ",").join(to + ",");
			data = data.split(from + ".").join(to + ".");
			data = data.split(from + " ").join(to + " ");
			data = data.split(from + "\n").join(to + "\n");
			return data;
		}
		
		/**
		 * 定数名に対応するインデックスを取得
		 * @param	id
		 * @return
		 */
		public function getConstantIndex(id:String):int
		{
			if (constantIndexLink[id] === undefined)
			{
				return -1;
			}
			return constantIndexLink[id];
		}
		
		/**
		 * 未登録IDのテクスチャの場合はリストに追加。登録済みIDならテクスチャを差し替え。
		 * @param	id	最初はアンドで始める
		 * @param	texture
		 */
		public function addTexture(id:String, texture:TextureResource, shader:MaterialShader):AGALTexture 
		{
			if (id.charAt(0) != "&")
			{
				throw new Error("テクスチャ定数のIDは&から始めてください。(ERROR: " + id + ")");
			}
			var n:int = textureList.length;
			var agalTexture:AGALTexture;
			//同一IDのテクスチャが登録済みだった場合は？
			for (var i:int = 0; i < n; i++) 
			{
				agalTexture = textureList[i];
				if (agalTexture.id == id)
				{
					throw new Error("既に登録済みのテクスチャ定数IDです。(ERROR: " + id + ")");
					//テクスチャリソースの差し替え（元シェーダーへの変更の通知ができなくなる？）
					agalTexture.texture = texture;
					agalTexture.linkShader(shader);
					return agalTexture;
				}
			}
			agalTexture = new AGALTexture(id, texture);
			agalTexture.linkShader(shader);
			textureList.push(agalTexture);
			
			return agalTexture;
		}
		
		public function clone():AGALCode 
		{
			var code:AGALCode = new AGALCode(programType);
			for (var key:String in usedVarying) 
			{
				code.usedVarying[key] = true;
			}
			code.codeLines = codeLines.concat();
			
			var i:int;
			var n:int;
			n = constantList.length;
			for (i = 0; i < n; i++) 
			{
				code.constantList.push(constantList[i].clone());
			}
			n = textureList.length;
			for (i = 0; i < n; i++) 
			{
				code.textureList.push(textureList[i].clone());
			}
			return code;
		}
		
	}

}
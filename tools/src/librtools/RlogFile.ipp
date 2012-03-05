// $Id: RlogFile.ipp 365 2011-02-28 07:28:26Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFile.ipp 365 2011-02-28 07:28:26Z mueller $
  \brief   Implemenation (inline) of RlogFile.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::ostream& RlogFile::operator()()
{
  return fpExtStream ? *fpExtStream : fIntStream;
}

} // end namespace Retro

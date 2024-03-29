// $Id: RlinkCommandExpect.ipp 375 2011-04-02 07:56:47Z mueller $
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
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandExpect.ipp 375 2011-04-02 07:56:47Z mueller $
  \brief   Implemenation (inline) of class RlinkCommandExpect.
*/

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommandExpect::SetStatus(uint8_t stat, uint8_t statmsk)
{
  fStatusVal = stat;
  fStatusMsk = statmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommandExpect::SetData(uint16_t data, uint16_t datamsk)
{
  fDataVal = data;
  fDataMsk = datamsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommandExpect::SetBlock(const std::vector<uint16_t>& block)
{
  fBlockVal = block;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline void RlinkCommandExpect::SetBlock(
                   const std::vector<uint16_t>& block,
                   const std::vector<uint16_t>& blockmsk)
{
  fBlockVal = block;
  fBlockMsk = blockmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommandExpect::StatusValue() const
{
  return fStatusVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint8_t RlinkCommandExpect::StatusMask() const
{
  return fStatusMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint16_t RlinkCommandExpect::DataValue() const
{
  return fDataVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline uint16_t RlinkCommandExpect::DataMask() const
{
  return fDataMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline const std::vector<uint16_t>& RlinkCommandExpect::BlockValue() const
{
  return fBlockVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline const std::vector<uint16_t>& RlinkCommandExpect::BlockMask() const
{
  return fBlockMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommandExpect::StatusCheck(uint8_t val) const
{
  return (val|fStatusMsk) == (fStatusVal|fStatusMsk);
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommandExpect::DataCheck(uint16_t val) const
{
  return (val|fDataMsk) == (fDataVal|fDataMsk);
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommandExpect::StatusIsChecked() const
{
  return fStatusMsk != 0xff;
}

//------------------------------------------+-----------------------------------
//! FIXME_text

inline bool RlinkCommandExpect::DataIsChecked() const
{
  return fDataMsk != 0xffff;
}

} // end namespace Retro
